# 编译安装nginx及基于域名的虚拟主机配置：
1. 安装所需工具：
    ```
    yum install -y vim lrzsz tree screen psmisc lsof tcpdump wget ntpdate
    gcc gcc-c++ glibc glibc-devel pcre pcre-devel openssl openssl-devel systemd-devel
    net-tools iotop bc zip unzip zlib-devel bash-completion nfs-utils automake libxml2
    libxml2-devel libxslt libxslt-devel perl perl-ExtUtils-Embed
    ``` 
2. 下载源码包：
    ```
    wget http://nginx.org/download/nginx-1.14.2.tar.gz
    ```
3. 解包并进入目录：
    ```
    tar xvf nginx-1.14.2.tar.gz

    cd nginx-1.14.2.tar.gz
    ```
4. 编译：
    >编译是为了检查系统环境是否符合编译安装的需求（比如是否有gcc编译工具、是否支持编译参数当中的模块），并根据开启的参数等生成makefile文件为下一步做准备
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
5. 创建nginx用户，并将编译安装nginx的目录及目录下所有文件的属主和属组改为nginx：
    ```
    useradd -s /sbin/nologin -u 2000 nginx

    chown nginx.nginx /apps/nginx/
    ```
6. 验证版本及编译参数：
    ```
    /apps/nginx/sbin/nginx -v
    ```
7. 修改主配置文件：
    ```sh
    vim /apps/nginx/conf/nginx.conf

    user    nginx；    #更改开启nginx子进程的用户

    include /apps/nginx/conf/servers/*.conf;    #定义包含的子配置文件
    ```
8. 在子配置文件中定义虚拟主机：  
    ![avagar]()  
    ![avagar]()  
9. 创建虚拟主机的目录和主页文件:
    + 结构如下：  
    ![avagar]()  
    + 主页内容如下：  
    ![avagar]()      
10. 在Windows主机的hosts文件中添加解析：  
    ![avagar]()  
11. 测试：  
    ![avagar]()  
    ![avagar]()  
    ![avagar]()  
    ![avagar]()  