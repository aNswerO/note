# 编译安装httpd：
1. 使用yum安装需要的工具包：
    ```
    yum install -y gcc pcre-devle openssl-devel expat-devel autoconf libtool gcc-c++
    ```

2. 从apache官网下载最新版本的httpd、apr和apr-util

3. 解压缩源码包：
    ```
    tar xvf httpd-2.4.39.tar.gz
    tar xvf apr-util-1.6.1.tar.gz
    tar xvf apr-1.7.0.tar.gz
    ```
4. 将apr和apr-util复制到httpd的解压后的目录中：
    ```
    cp -r apr-1.7.0/ httpd-2.4.39/srclib/apr
    cp -r  apr-util-1.6.1/ httpd-2.4.39/srclib/apr-util
    ```
5. 编译安装：
    ```shell
    cd httpd-2.4.39/

    ./configure --prefix=/app/httpd24 --enable-so --enable-ssl --enable-cgi --enable-rewrite --with-zlib --with-pcre --with-included-apr --enable-modules=most --enable-mpms-shared=all --with-mpm=prefork

    make -j 2 && make install

    #安装目录为/app/httpd24
    ```
6. 添加环境变量：
    + 添加环境变量并使之生效：
        ```
        vim /etc/profile.d/httpd.sh
        PATH=/app/httpd24/bin:$PATH

        . /etc/profile.d/httpd.sh
        ```
    + 查看修改后的环境变量：
        ``` 
        ehco $PATH
        /app/httpd24/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin
        ```
7. 添加apache用户：
    ```shell
    useradd -r -s /sbin/nologin apache
    #添加系统用户，shell类型为nologin
    ```
8. 将配置文件中的user和group改为apache：
    ```
    vim /app/httpd24/conf/httpd.conf

    User apache
    Group apache
    ```
9. 将服务设置为开机自启：
    ```shell
    vim /etc/rc.d/rc.local
    /app/httpd24/bin/apachectl start
    #加上这一行

    chmod +x /etc/rc.d/rc.local
    ```
10. 测试能否启动：
    + 启动：
        ```
        apachectl start
        ```
    + 查看端口号和进程：
        ```
        ss -tnl

        ps aux | grep httpd
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/10th-week/pic/%E7%BC%96%E8%AF%91%E5%AE%89%E8%A3%85httpd/%E6%9F%A5%E7%9C%8B%E7%AB%AF%E5%8F%A3.png)  
        ![avagar](https://github.com/aNswerO/note/blob/master/10th-week/pic/%E7%BC%96%E8%AF%91%E5%AE%89%E8%A3%85httpd/%E6%9F%A5%E7%9C%8B%E8%BF%9B%E7%A8%8B.png)  
11. 测试开机自启：
    + 重启：
      ```
      init 6
      ```
    + 查看进程：
      ```
      ps aux | grep httpd
      ```  
      ![avagar](https://github.com/aNswerO/note/blob/master/10th-week/pic/%E7%BC%96%E8%AF%91%E5%AE%89%E8%A3%85httpd/%E6%B5%8B%E8%AF%95%E5%BC%80%E6%9C%BA%E8%87%AA%E5%90%AF.png)
