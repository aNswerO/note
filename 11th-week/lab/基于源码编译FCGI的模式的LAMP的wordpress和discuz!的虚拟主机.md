# 基于源码编译FCGI的模式的LAMP的wordpress和discuz!的虚拟主机:
## 实验环境：
+ 两台linux主机：
    + 192.168.1.143：安装有httpd-2.4.39、php-7.3.5
    + 192.168.1.128：安装有mariadb-5.5.60
+ 额外需要：
    + wordpress：wordpress-5.0.3.tar.gz
    + discuz：Discuz_X3.3_SC_UTF8.zip
## 在192.168.1.143上安装httpd-2.4.39：
>见(https://github.com/aNswerO/note/blob/master/10th-week/lab/%E7%BC%96%E8%AF%91%E5%AE%89%E8%A3%85httpd.md)
## 在192.168.1.128上安装mariadb-5.5.60：
``` 
    yum install -y mariadb-server
```
## 实验步骤：
1. 在192.168.1.143上做配置：
    + 编辑主配置文件：
        ```shell
        vim /app/httpd24/conf/httpd.conf

        LoadModule proxy_module modules/mod_proxy.so
        #mod_proxy.XXX的核心模块，启用此模块使下面的模块启用生效
        LoadModule proxy_fcgi_module modules/mod_proxy_fcgi.so
        #启用此模块，使当前服务器充当PHP客户端

        DirectoryIndex index.php index.html
        #修改apache默认起始（索引）界面，添加index.php
        ```
    + 修改虚拟主机的配置文件如下图：  
        ![avagar]()
2. 编译安装php-7.3.5：
    1. 安装所需包：
        ```shell
        yum install -y libxml2-devel bzip2-devel libmcrypt-devel
        #需要配置EPEL源
        ```

    2. 解压包：
        ```
        tar xvf php-7.3.5.tar.bz2
        ```
    3. 编译安装：
        ```
        ./configure --prefix=/app/php --enable-mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-openssl --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --with-config-file-path=/etc --with-config-file-scan-dir=/etc/php.d --enable-mbstring --enable-xml --enable-sockets --enable-fpm --enable-maintainer-zts --disable-fileinfo

        make -j 2 && make install
        ```
3. 配置所需文件：
    1. cd php-7.3.5/

    2. 准备php的核心配置文件，并在其中修改以修改时区：
        ```
        cp php.ini-production  /etc/php.ini

        vim /etc/php.ini
        ```  
        ![avagar]()
    3. 准备php-fpm的服务脚本：
        ```shell
        cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm

        chmod +x /etc/init.d/php-fpm
        #为服务脚本增加执行权限
        ```
    4. 准备php-fpm服务的配置文件：
        ```shell
        cd /app/php/etc/

        cp php-fpm.conf.default php-fpm.conf
        ```
    5. 准备php-fpm服务的扩展配置文件：
        ```
        cd /app/php/etc/php-fpm.d/

        cp www.conf.default www.conf
        ```
    6. 修改php-fpm服务的扩展配置文件的内容：
        ```shell
        vim www.conf
        ```  
        ![avagar]()  
    7. 启动php-fpm服务：
        ```
        service php-fpm start
        ```
4. 准备相关的php程序文件：
    1. 解压WordPress和discuz包到/app/下：
        ```
        cd /app/

        unzip Discuz_X3.3_SC_UTF8.zip /app/discuz/

        tar xvf wordpress-5.0.3-zh_CN.tar.gz

        ```
    2. 为/app/discuz/目录添加ACL：
        ```shell
        cd /app

        setfacl -Rm u:apache:rwx discuz
        ```
    3. 为/app/wordpress/目录添加ACL：
        ```
        cd /app
        
        setfacl -Rm u:apache:rwx wordpress
        ```
5. 重启服务：
    ```
    systemctl restart php-fpm

    apachectl restart
    ```
6. 在windows主机修改C:\Windows\System32\drivers\etc/hosts文件，以实现本地域名解析：  
    ![avagar]()
    >要先把文件移动到桌面，进行修改后再移动回原目录
7. 测试：  
    + 测试WordPress：  
        ![avagar]()  
    + 测试discuz：  
        ![avagar]()  
8. wordpress和discuz连接数据库：
    + wordpress连接数据库：
        1. 在浏览器输入URL：www.wpsite.com

        2. 按wordpress提示填入对应信息（忘记截图）：
            ```shell
            数据库名称：wordpress
            用于连接数据库的用户名：wpuser
            #已在数据库服务器授权
            此用户的密码：centos
            邮箱：xxx@xx.com
            #可以随便填，但是不能不填
            数据库的表前缀：wp_
            ```
        3. 填入上述信息后等待创建数据库文件和表内容，安装后如图：  
            ![avagar]()  
            ![avagar]()  
    + discuz连接数据库：
        1. 在浏览器输入URL：www.discuzsite.com/install（安装时要指定install路径，在安装完成后要删除install目录）：  
            ![avagar]()  
            >如果没有在之前给discuz目录设置ACL，使apache用户对应权限，目录、文件权限检查的状态会显示红叉，无法继续安装

        2. 按提示安装discuz：
            ![avagar]()  
            ![avagar]()  
            ![avagar]()  
            ![avagar]()  
            ![avagar]()  
