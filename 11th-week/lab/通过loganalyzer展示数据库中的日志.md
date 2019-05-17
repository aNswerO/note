# 通过loganalyzer展示数据库中的日志：
1. 安装mariadb-server

2. 在mysql中新建一个rsyslog用户，并授权其能连接至此数据库服务器：
    ```
    GRANT ALL ON Syslog.* TO rsyslog@'loaclhost' IDENTIFIED BY 'centos';
    ```
3. 安装mysql模块相关的程序包：
    ```
    yum install -y rsyslog-mysql
    ```
4. 为rsyslog创建数据库及表：
    ```
    mysql < /usr/share/doc/rsyslog-8.24.0/mysql-createDB.sql
    ```  
    ![avagar](https://github.com/aNswerO/note/blob/master/11th-week/pic/logrotate/%E5%AF%BC%E5%85%A5%E6%95%B0%E6%8D%AE%E5%BA%93%E6%96%87%E4%BB%B6.png)  
    ![avagar](https://github.com/aNswerO/note/blob/master/11th-week/pic/logrotate/%E8%A1%A8.png)  
5. 配置rsyslog将日志保存到mysql中：
    + 修改rsyslog的配置文件,在指定区域添加两行：
    ```
    vim /etc/rsyslog.conf

    #### MODULES ####
    $ModLoad ommysql

    #### RuleS ####
    *.* :ommysql:localhost,Syslog,rsyslog,centos
    ```
6. 准备lamp组合：
    >搭建lamp详见（）
    + 编辑httpd主配置文件，在最后添加如下几行：  
        ```
        vim /etc/httpd/conf/httpd.conf
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/11th-week/pic/logrotate/httpd.conf.png)
    + 编辑php.ini文件，修改时区：
        ```
        vim /etc/php.ini

        date.timezone = asia/shanghai
        ```
7. 安装程序包：
    ```
    yum install -y php php-mysql php-gd
    ```
8. 安装loganalyzer：
    1. 下载并解压：
        ```
        tar xvf loganalyzer-4.1.7
        ```
    2. 将loganalyzer中的内容放置到网站上：
        ```
        cd loganalyzer-4.1.7
        cp -a src/ /var/www/html/loganalyzer
        ```
    3. 创建.php文件并修改权限：
        ```
        cd /var/www/html/loganalyzer
        touch config.php
        chmod 666 config.php
        ```
    4. 安装并测试：  
        ![avagar](https://github.com/aNswerO/note/blob/master/11th-week/pic/logrotate/7.png)  
        >这一步默认的数据库和表名称为小写，需要注意大小写  
        ![avagar](https://github.com/aNswerO/note/blob/master/11th-week/pic/logrotate/%E6%B5%8B%E8%AF%95.png)  
