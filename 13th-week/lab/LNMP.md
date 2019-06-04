# LNMP：
## 实验相关知识：
### FastCGI：
+ CGI：
    ```
        早期的web服务器只能简单地响应浏览器发来的HTTP请求，并将服务器本地的html文件返回给浏览器，即静态html文件。
        但是随着网站功能增加，网站的开发也变得复杂，以至于出现动态技术，如php、java语言开发的网站，但是web服务器不能直接运行php这样的文件。
        nginx通过某种特定协议将客户端请求转发给第三方服务处理；第三方服务器会新建新的进程处理用户的请求，处理完成后返回数据给nginx并回收进程，最后由nginx返回给客户端；这个特定的协议就是CGI（common gateway interface：通用网关接口）协议，CGI协议是web服务器和外部应用程序之间的接口标准，是cgi程序和服务器之间传递信息的标准化接口
    ```
+ FastCGI：
    ```
        CGI协议虽然解决了语言解析器和web服务器之间通信的问题，但其效率很低；因为web服务器没收到一个请求都会创建一个CGI进程，在请求结束后再关闭进程。
        而FastCGI每次处理完请求不会关闭进程，而是保留下这个进程，使这个进程能处理多个请求，提高了效率
    ```
+ PHP-FPM：
    ```
        PHP-FPM（FastCGI Process Manager：FastCGI进程管理器）
        PHP-FPM是一个实现了FastCGI的程序，它提供了进程管理的功能，进程包括主进程（master）和工作进程（worker）；主进程只有一个，负责监听端口，并接收来自web服务器的请求；工作进程一般会有多个，每个工作进程中都会嵌入一个PHP解析器，负责进行PHP代码的处理
    ```
## 搭建LNMP：
+ 实验用软件版本：
    + Linux：CentOS 7.6

    + nginx：1.12.2
    + mariadb：10.2.23
    + PHP：7.2.19
    + wordpress：5.0.3
+ 实验主机：
    + nginx + PHP：192.168.1.159

    + mysql服务器：192.168.1.137
    + NFS服务器：192.168.1.50
+ 实验步骤：
1. 配置NFS服务器：
    1. 在NFS服务器上创建共享目录/data（放置有解压完成的wordpress目录），并修改属主属组：
        ```
        mkdir /data

        chown -R nfsnobody.nfsnobody /data
        ```
    2. 编辑/etc/exports文件，使nginx服务器可以挂载并访问共享目录下的内容：
        ```
        vim /etc/exports

        /data 192.168.1.159(rw)
        ```
        ```
        exportfs -r
        ```
    3. 启动rpcbind、nfs服务：
        ```
        systemctl start rpcbind nfs
        ```
    4. 查看nfs服务器上共享了哪些目录：
        ```
        showmount -e
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/13th-week/pic/LNMP/%E6%9F%A5%E7%9C%8B%E5%85%B1%E4%BA%AB%E7%9B%AE%E5%BD%95.png)  
    5. 在nginx服务器上挂载nfs服务器的共享目录：
        ```
        mount 192.168.1.50:/data /mnt
        ```
        ```sh
        df    #查看挂载情况
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/13th-week/pic/LNMP/%E6%8C%82%E8%BD%BD%E5%85%B1%E4%BA%AB%E7%9B%AE%E5%BD%95.png)  
2. 配置nginx + PHP服务器：
    + 部署php-fpm：
        1. 安装所需工具：
            ```
            yum -y install wget vim pcre pcre-devel openssl openssl-devel libicu-devel gcc gcc-c++ autoconf libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel ncurses ncurses-devel curl curl-devel krb5-devel libidn libidn-devel openldap openldap-devel nss_ldap jemalloc-devel cmake boost-devel bison automake libevent libevent-devel gd gd-devel libtool* libmcrypt libmcrypt-devel mcrypt mhash libxslt libxslt-devel readline readline-devel gmp gmp-devel libcurl libcurl-devel openjpeg-devel
            ```
        2. 下载源码包：
            ```
            wget https://www.php.net/distributions/php-7.2.19.tar.xz
            ```
        3. 解包：
            ```
            tar xvf nginx-1.12.2.tar.gz
            tar xvf php-7.2.19.tar.xz
            ```
        4. 编译：
            ```
            cd /src/php-7.2.19
            ```
            ```
            ./configure --prefix=/apps/php --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-pear --with-curl --with-png-dir --with-freetype-dir --with-iconv --with-mhash --with-zlib --with-xmlrpc --with-xsl --with-openssl --with-mysqli --with-pdo-mysql --disable-debug --enable-zip --enable-sockets --enable-soap --enable-inline-optimization --enable-xml --enable-ftp --enable-exif --enable-wddx --enable-bcmath --enable-calendar --enable-shmop --enable-dba --enable-sysvsem --enable-sysvshm --enable-sysvmsg
            ```
            ```
            make && make install
            ```
        + 准备PHP的配置文件：
            ```
            cd /apps/php/etc/php-fpm.d/
            ```
            ```
            cp www.conf.default www.conf
            ```
            ```
            cp /src/php-7.2.19/php.ini-production /apps/php/etc/php.ini
            ```
            ```
            useradd -s /sbin/nologin -u 1002 www
            ```
            ```sh
            vim www.conf
            #修改配置文件内容如下图
            ```  
            ![avagar](https://github.com/aNswerO/note/blob/master/13th-week/pic/LNMP/www%E9%85%8D%E7%BD%AE.png)  
            ```
            cd /apps/php/etc/
            ```
            ```
            cp php-fpm.conf.default php-fpm.conf
            ```
            ```sh
            mkdir /apps/php/log   #创建用于存放日志的目录
            ```
        + 启动php-fpm并验证：
            + 启动：
                ```sh
                /apps/php/sbin/php-fpm -t    #检查配置文件是否有错误
                ```
                ```sh
                /apps/php/sbin/php-fpm -c /apps/php/etc/php.ini    #启动php-fpm
                ```  
            + 验证：  
                ![avagar](https://github.com/aNswerO/note/blob/master/13th-week/pic/LNMP/%E9%AA%8C%E8%AF%81php.png)  
    + 部署nginx：
        1. 创建用户，并将编译安装nginx的目录及目录下所有文件的属主和属组改为nginx：
            ```
            useradd -s /sbin/nologin -u 2000 nginx
            ```
            ```
            chown nginx.nginx /apps/nginx/
            ```
        2. 下载所需工具：
            ```
            yum install -y vim lrzsz tree screen psmisc lsof tcpdump wget ntpdate gcc gcc-c++ glibc glibc-devel pcre pcre-devel openssl openssl-devel systemd-devel net-tools iotop bc zip unzip zlib-devel bash-completion nfs-utils automake libxml2 libxml2-devel libxslt libxslt-devel perl perl-ExtUtils-Embed
            ```
        3. 下载源码包：
            ```
            wget https://nginx.org/download/nginx-1.12.2.tar.gz
            ```
        4. 解包并进入目录：
            ```
            tar xvf nginx-1.12.2.tar.gz
            ```
            ```
            cd nginx-1.12.2
            ```
        5. 编译：
            ```
            ./configure --prefix=/apps/nginx \
            --user=nginx \
            --group=nginx \
            --with-http_ssl_module \
            --with-http_v2_module \
            --with-http_realip_module \
            --with-http_stub_status_module \
            --with-http_gzip_static_module \
            --with-pcre \
            --with-stream \
            --with-stream_ssl_module \
            --with-stream_realip_module

            make && make install
            ```
        7. 创建软链接：
            ```
            cd /usr/local/bin
            ```
            ```
            ln -s /apps/nginx/sbin/nginx nginx
            ```   
        6. 验证版本及编译参数：
            ```
            nginx -V
            ```
        7. 修改主配置文件：
            ```sh
            vim /apps/nginx/conf/nginx.conf

            user    nginx;   
            include /apps/nginx/conf/servers/*.conf;    #引用扩展配置文件
            ```
        8. 启动nginx：
            ```sh
            nginx -t    #检查配置文件是否有错误
            ```
            ```sh
            nginx    #启动nginx
            ```
        9. 创建并配置虚拟主机配置文件/apps/nginx/conf/servers/wordpress.conf：
            ```
            vim /apps/nginx/conf/servers/wordpress.conf
            ```  
            ![avagar](https://github.com/aNswerO/note/blob/master/13th-week/pic/LNMP/nginx%E8%99%9A%E6%8B%9F%E4%B8%BB%E6%9C%BA%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6.png)  
3. 部署数据库服务器：
    1. 准备用户：
        ```
        groupadd -r -g 306 mysql
        useradd -r -g 306 -u 306 -s /sbin/nologin/ mysql
        ```
    2. 准备数据目录：
        ```
        mkdir -pv /data/mysql
        ```
        ```
        chown mysql.mysql /data/mysql
        ```
    3. 准备二进制程序：
        ```
        tar xvf mariadb-10.2.23-linux-x86_64.tar.gz -C /usr/local
        ```
        ```
        cd /usr/local
        ```
        ```
        ln -sv mariadb-10.2.23-linux-x86_64/ mysql
        ```
        ```
        chown -R root.mysql mysql/
        ```
    4. 准备配置文件：   
        ```
        mkdir /etc/mysql/
        ```
        ```
        cp support-files/my-large.cnf /etc/mysql/my.cnf
        ```
        ```sh
        vim /etc/mysql/my.cnf

        #添加下面几行：
        datadir = /data/mysql
        innodb_file_per_table = on
        skip_name_resolve = on
        ```
    5. 创建数据库文件：
        ```
        cd /usr/local/mysql
        ```
        ```
        ./scripts/mysql_install_db --datadir=/data/mysql --user=mysql
        ```
        >在创建数据库文件时出现了一个如下图的错误，创建数据库文件失败，解决方法是安装libaio  

        ![avagar](https://github.com/aNswerO/note/blob/master/13th-week/pic/LNMP/%E9%94%99%E8%AF%AF.png)  
        ```
        yum install -y libaio
        ```
    6. 准备服务脚本并启动服务：
        ```
        cp support-files/mysql.server /etc/rc.d/init.d/mysqld
        ```
        ```
        chkconfig --add mysqld
        ```
        ```
        service mysqld start
        ```
    7. 添加环境变量并使之生效：
        ```
        echo 'PATH=/usr/local/mysql/bin:$PATH' > /etc/profile.d/mysql
        ```
        ```
        . /etc/profile.d/mysql
        ```
    8. 连接数据库，新建一个名为wordpress的数据库：
        ```
        mysql> create database wordpress;
        ```
    9. 新建一个在nginx服务器（192.168.1.159）登录且名为wpuser的用户并授权，使其具有关于wordpress数据库中的所有表的权限，密码为centos：
        ```
        msyql> grant all on wordpress.* to wpuser@'192.168.1.159' identified by 'centos';
        ```
    10. 刷新mysql的系统权限相关表，使刚授权的用户生效：
        ```
        mysql> flush privileges;
        ```
4. 测试：  
    ![avagar](https://github.com/aNswerO/note/blob/master/13th-week/pic/LNMP/%E6%B5%8B%E8%AF%95_1.png)  
    ![avagar](https://github.com/aNswerO/note/blob/master/13th-week/pic/LNMP/%E6%B5%8B%E8%AF%95_2.png)  
    ![avagar](https://github.com/aNswerO/note/blob/master/13th-week/pic/LNMP/%E6%B5%8B%E8%AF%95_3.png)  
    ![avagar](https://github.com/aNswerO/note/blob/master/13th-week/pic/LNMP/%E5%AE%89%E8%A3%85%E5%AE%8C%E6%88%90.png)  
    >使用Windows的浏览器访问需要进行本地解析，即编辑C:\Windows\System32\drivers\etc\hosts文件，添加一条解析记录
