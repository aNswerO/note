# 制作docker镜像（Ubuntu 18.04.1 LTS）：
+ 镜像中没有内核：
    >镜像在启动后直接使用宿主机的内核，镜像本身只提供响应的rootfs，即系统正常运行所必需的用户空间的文件系统，所以容器中的/boot目录没有任何文件
+ 镜像的作用：
    >按公司实际业务需求将需要的软件、相关配置等基础环境配置完成，然后将其做成镜像，最后再从镜像批量生产容器可以极大地简化相同环境的部署工作
+ 制作镜像的方法：
    + 手动制作

    + 自动制作：基于DockerFile
## 手动制作nginx镜像：
>由于是基于一个基础镜像重新制作镜像，因此要先准备一个基础镜像，这里使用官方提供的centos镜像
1. 从官方仓库拉取一个centos镜像到本地：
    ```
    [root@docker_1 ~]#docker pull centos
    ```
    >未指定版本号，TAG默认为latest，即拉取最新版的centos镜像
2. 基于此镜像创建并进入容器：
    ```
    [root@docker ~]#docker run -it centos /bin/bash
    ```
3. 安装所需包：
    ```
    [root@d926d6dfe741 /]# yum install -y wget
    ```
4. 更换yum源：
    + 删除自带yum源：
        ```
        [root@d926d6dfe741 /]# rm -rf /etc/yum.repos.d/*
        ```
    + 下载yum源：
        ```
        [root@d926d6dfe741 /]# wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

        [root@d926d6dfe741 /]# wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
        ```
5. yum安装nginx和常用命令：
    + 安装nginx：
        ```
        [root@d926d6dfe741 /]# yum install -y nginx
        ```
    + 安装常用命令：
        ```
        [root@d926d6dfe741 /]# yum install -y vim wget pcre pcre-devel zlib zlib-devel openssl openssl-devel iproute net-tools iotop
        ```
6. 配置nginx：
    + 关闭nginx后台运行：
        ```
        [root@d926d6dfe741 /]# vim /etc/nginx/nginx.conf
        ```
        >在include设置块上方添加daemon off;
    + 自定义web页面：
        ```
        [root@d926d6dfe741 /]# vim /usr/share/nginx/html/index.html 

        Docker Nginx Website
        ```
7. 提交为镜像：
    + 在宿主机基于容器ID提交为镜像：
        ```
        [root@docker ~]#docker commit -m "nginx image" d926d6dfe741 centos-nginx

        sha256:15c222cde2c3b2e373d9aa57a45b2fd5ac25546d6da434136a53908fceb27b12
        ```
    + 标记tag提交为镜像：
        >生产中常用，后期可以根据tag标记使用不同版本的镜像
        ```
        [root@docker ~]#docker commit -m "nginx image" d926d6dfe741 centos-nginx:v1
        sha256:3953c5b16d77cc371bdf4683e4e42db008194d1720e31c28e98f37021d81be8a
        ```
    + 查看镜像：
        ```
        [root@docker ~]#docker images
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/18th-week/pic/docker%E5%88%B6%E4%BD%9C%E9%95%9C%E5%83%8F/%E6%9F%A5%E7%9C%8B%E9%95%9C%E5%83%8F.png)  
8. 启动容器：
    ```
    [root@docker ~]#docker run -d -p 80:80 --name centos_nginx centos-nginx /usr/sbin/nginx
    ```  
    ![avagar](https://github.com/aNswerO/note/blob/master/18th-week/pic/docker%E5%88%B6%E4%BD%9C%E9%95%9C%E5%83%8F/%E5%90%AF%E5%8A%A8%E5%AE%B9%E5%99%A8.png)  
9. 测试：  
    ![avagar](https://github.com/aNswerO/note/blob/master/18th-week/pic/docker%E5%88%B6%E4%BD%9C%E9%95%9C%E5%83%8F/%E6%B5%8B%E8%AF%95.png)  
## 自动制作镜像：
>基于DockerFile
+ DockerFile：
    ```
        一种可以被docker程序解释的脚本，由一条一条命令组成（其有自己的书写方式和支持的命令），每一条命令对应Linux下的一条命令，docker程序将这些DockerFile指令翻译成真正的Linux命令  
        docker程序读取DockerFile并根据指令生成docker镜像，相比于手动制作镜像，DockerFile更能直观地展示镜像是怎么产生的  
        有了DockerFile，当后期有额外的需求时，只要在之前的DockerFile中添加或修改相应的命令就能重新生成新的docker镜像，避免了手动制作镜像的麻烦
    ```
### 业务镜像制作（nginx/JDK/tomcat）：
1. 下载基础centos镜像：
    ```
    [root@docker_2 ~]#docker pull centos
    ```
2. 准备目录和所需源码包：
    + 创建目录：
        ```
        [root@docker_2 ~]#mkdir -pv /opt/dockerfile/{lb/haproxy,web/{nginx,tomcat,apache,jdk},system/{centos,redhat,ubuntu}}
        ```
    + 查看目录结构：
        ```
        [root@docker_2 ~]#tree /opt/
        /opt/
        └── dockerfile
            ├── lb
            │   └── haproxy
            │       └── haproxy-1.8.12.tar.gz
            ├── system
            │   ├── centos
            │   ├── redhat
            │   └── ubuntu
            └── web
                ├── apache
                ├── jdk
                │   └── jdk-8u211-linux-x64.tar.gz
                ├── nginx
                └── tomcat
                    └── apache-tomcat-8.5.42.tar.gz

        12 directories, 3 files
        ```
3. 构建jdk镜像（基于centos镜像）：
    + 编写Dockerfile文件：
        + root@docker_2 jdk]#vim Dockerfile
        ```Dockerfile
        FROM centos:latest
        ADD jdk-8u211-linux-x64.tar.gz /usr/local/src/
        RUN ln -s /usr/local/src/jdk1.8.0_211 /usr/local/jdk
        ADD profile /etc/profile
        ENV JAVA_HOME /usr/local/jdk
        ENV JRE_HOME $JAVA_HOME/jre
        ENV CLASSPATH $JAVA_HOME/lib/:$JRE_HOME/lib/
        ENV PATH $PATH:$JAVA_HOME/bin
        RUN rm -rf /etc/localtime && ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone
        ```
    + 准备profile文件：
        >从centos主机拷贝一份/etc/profile文件，加上如下几行，放在当前目录下：
        ```
        export JAVA_HOME=/usr/local/jdk
        export TOMCAT_HOME=/apps/tomcat
        export PATH=$JAVA_HOME/bin:$JAVA_HOME/jre/bin:$TOMCAT_HOME/bin:$PATH
        export CLASSPATH=.$CLASSPATH:$JAVA_HOME/lib:$JAVA_HOME/jre/lib:$JAVA_HOME/lib/tools.jar
        ```
    + 构建镜像（jdk源码包要和Dockerfile文件放在同一目录下）：
        ```
        [root@docker_2 jdk]#docker build -t centos_jdk:v1 .
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/18th-week/pic/docker%E5%88%B6%E4%BD%9C%E9%95%9C%E5%83%8F/centos_jdk%E9%95%9C%E5%83%8F%E5%88%B6%E4%BD%9C.png)  
    + 从镜像启动容器：
        ```
        [root@docker_2 jdk]#docker run -it --rm centos_jdk:v1 bash
        ```  
        >验证JDK版本和时区  

        ![avagar](https://github.com/aNswerO/note/blob/master/18th-week/pic/docker%E5%88%B6%E4%BD%9C%E9%95%9C%E5%83%8F/%E5%AE%B9%E5%99%A8%E5%86%85%E6%9F%A5%E7%9C%8Bjava%E5%92%8C%E6%97%B6%E9%97%B4.png)  
3. 构建tomcat镜像（基于上面制作的centos_jdk:v1镜像）：
    + 编写Dockerfile：
        + [root@docker_2 tomcat]#vim Dockerfile
            ```Dockerfile
            FROM centos_jdk:v1
            RUN useradd www -u 2000
            ENV TZ "/Asia/Shanghai"
            ENV LANG en_US.UTF-8
            ENV TERM xterm
            ENV TOMCATCAT_MAJOR_VERSION 8
            ENV TOMCAT_MINOR_VERSION 8.5.42
            ENV CATALILNA_HOME /apps/tomcat
            ENV APP_DIR ${CATALINA_HOME}/webapps
            RUN mkdir /apps
            ADD apache-tomcat-8.5.42.tar.gz /apps/
            RUN ln -s /apps/apache-tomcat-8.5.42 /apps/tomcat
            ```
    + 构建镜像：
        ```
        [root@docker_2 tomcat]#docker build -t tomcat_base:v1 .
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/18th-week/pic/docker%E5%88%B6%E4%BD%9C%E9%95%9C%E5%83%8F/%E5%AE%B9%E5%99%A8%E5%86%85%E6%9F%A5%E7%9C%8Bjava%E5%92%8C%E6%97%B6%E9%97%B4.png)  
    + 进入容器:
        ```
        [root@docker_2 web]#docker run -it --rm tomcat_base:v1 bash
        ```
4. 构建业务镜像：
    + tomcat website_1：
        + 创建目录，tomcat目录结构如下：  
            ```
            [root@docker_2 web]#tree tomcat/
            tomcat/
            ├── apache-tomcat-8.5.42.tar.gz
            ├── Dockerfile
            └── server1
                ├── tomcat1
                └── tomcat2

            3 directories, 2 files
            ```
        + 进入tomcat1目录，编写Dockerfile：
            + 切换目录：
                ```
                [root@docker_2 web]#cd /opt/dockerfile/web/tomcat/server1/tomcat1
                ```
            + 编写Dockerfile：
                + [root@docker_2 tomcat1]#vim Dockerfile
                ```Dockerfile
                FROM tomcat_base:v1
                ADD myapp/* /apps/tomcat/webapps/myapp/
                ADD run_tomcat.sh /apps/tomcat/bin/run_tomcat.sh
                RUN chmod u+x /apps/tomcat/bin/run_tomcat.sh
                RUN chown www.www /apps/ -R
                CMD ["/apps/tomcat/bin/run_tomcat.sh"]
                EXPOSE 8080 8009
                ```
            + 容器启动执行脚本run_tomcat.sh：
                ```sh
                #!/bin/bash
                echo "192.168.6.101 test.qyh.com" >> /etc/hosts
                echo "nameserver 114.114.114.114" > /etc/resolv.conf
                su - www -c '/apps/tomcat/bin/catalina.sh start'
                tail /etc/hosts
                tail -f /etc/resolv.conf
                ```
                >后面的tail命令加上-f选项是为了测试时保持容器运行，如果不加-f，启动容器后执行过脚本中的命令后，容器会自动关闭
            + 自定义页面：
                + 创建目录：
                    ```
                    [root@docker_2 tomcat1]#mkdir myapp
                    ```
                + 创建页面文件：
                    ```
                    [root@docker_2 tomcat1]#echo "tomcat website 1" > myapp/index.html
                    ```
            + 构建镜像：
                ```
                [root@docker_2 tomcat1]#docker build -t tomcat_webapp1:v1 .
                ```  
                ![avagar](https://github.com/aNswerO/note/blob/master/18th-week/pic/docker%E5%88%B6%E4%BD%9C%E9%95%9C%E5%83%8F/tomcat_1%E9%95%9C%E5%83%8F%E5%88%B6%E4%BD%9C.png)  
            + 启动容器测试：
                ```
                [root@docker_2 tomcat1]#docker run -it -p 8888:8080 tomcat_webapp1:v1
                ```  
                ![avagar](https://github.com/aNswerO/note/blob/master/18th-week/pic/docker%E5%88%B6%E4%BD%9C%E9%95%9C%E5%83%8F/%E5%90%AF%E5%8A%A8tomcat1.png)  
                ![avagar](https://github.com/aNswerO/note/blob/master/18th-week/pic/docker%E5%88%B6%E4%BD%9C%E9%95%9C%E5%83%8F/%E6%B5%8B%E8%AF%95%E7%BD%91%E9%A1%B5.png)  
    + tomcat website_2：
        >将tomcat1目录下的所有文件拷贝到tomcat2目录下，只需更改myapp目录下的页面文件内容即可
        + 目录结构：
            ```
            [root@docker_2 web]#tree tomcat/
            tomcat/
            ├── apache-tomcat-8.5.42.tar.gz
            ├── Dockerfile
            └── server1
                ├── tomcat1
                │   ├── Dockerfile
                │   ├── myapp
                │   │   └── index.html
                │   ├── run_tomcat.sh
                │   └── server.xml
                └── tomcat2
                    ├── Dockerfile
                    ├── myapp
                    │   └── index.html
                    ├── run_tomcat.sh
                    └── server.xml

            5 directories, 10 files
            ```
        + 构建镜像：
            ```
            [root@docker_2 tomcat2]#docker build -t tomcat_webapp2:v1 .
            ```
        + 启动容器测试：
            >使用另一个未被占用的端口8889
            ```
            [root@docker_2 tomcat2]#docker run -it -p 8889:8080 tomcat_webapp2:v1 
            ```  
            ![avagar](https://github.com/aNswerO/note/blob/master/18th-week/pic/docker%E5%88%B6%E4%BD%9C%E9%95%9C%E5%83%8F/%E5%90%AF%E5%8A%A8tomcat2.png)  
            ![avagar](https://github.com/aNswerO/note/blob/master/18th-week/pic/docker%E5%88%B6%E4%BD%9C%E9%95%9C%E5%83%8F/%E6%B5%8B%E8%AF%95%E7%BD%91%E9%A1%B52.png)  
5. 构建haproxy镜像：
    + 切换目录：
        ```
        [root@docker_2 haproxy]#cd /opt/dockerfile/lb/haproxy
        ```
    + 编写Dockfile：
        + vim Dockerfile
        ```Dockerfile
        FROM centos:latest

        ADD haproxy-1.8.12.tar.gz /usr/local/src

        RUN yum install gcc gcc c++ glibc glibc-devel pcre pcre-devel openssl openssl-devel systemd-devel net-tools vim iotop bc zip unzip zlib-devel lrzsz tree screen lsof tcpdump wget ntpdate -y && cd /usr/local/src/haproxy-1.8.12 && make ARCH=x86_64 TARGET=linux2628 USE_PCRE=1 USE_OPENSSL=1 USE_ZLIB=1 USE_SYSTEMD=1  USE_CPU_AFFINITY=1  PREFIX=/usr/local/haproxy && make install PREFIX=/usr/local/haproxy && cp haproxy  /usr/sbin/ && mkdir /usr/local/haproxy/run

        ADD haproxy.cfg /etc/haproxy/haproxy.cfg

        ADD run_haproxy.sh /usr/bin/run_haproxy.sh

        EXPOSE 80 9999

        CMD ["/usr/bin/run_haproxy.sh"]
        ```
    + 准备配置文件（haproxy.cfg）：
        ```
        global
        maxconn 100000
        chroot /usr/local/haproxy
        #stats socket /var/lib/haproxy/haproxy.sock mode 600 level admin
        uid 99
        gid 99
        daemon
        #nbproc 2
        #cpu-map 1 0
        #cpu-map 2 1
        pidfile /usr/local/haproxy/run/haproxy.pid
        log 127.0.0.1 local3 info

        defaults
        option http-keep-alive
        option  forwardfor
        maxconn 100000
        mode http
        timeout connect 300000ms
        timeout client  300000ms
        timeout server  300000ms

        listen stats
        mode http
        bind 0.0.0.0:9999
        stats enable
        log global
        stats uri     /haproxy-status
        stats auth    haadmin:123456

        listen  web_port
        bind 0.0.0.0:80
        mode http
        log global
        server web1  192.168.6.101:8888  check inter 3000 fall 2 rise 5
        server web2  192.168.6.101:8889  check inter 3000 fall 2 rise 5
        ```
    + 准备haproxy的启动脚本（run_haproxy.sh）：
        >需要可执行权限
        ```sh
        #!/bin/bash
        haproxy -f /etc/haproxy/haproxy.cfg
        tail -f /etc/hosts
        ```
    + 现在haproxy目录下的文件：  
        ```
        [root@docker_2 lb]#tree haproxy/
        haproxy/
        ├── Dockerfile
        ├── haproxy-1.8.12.tar.gz
        ├── haproxy.cfg
        └── run_haproxy.sh

        0 directories, 4 files
        ```
    + 构建镜像：
        ```
        [root@docker_2 lb]#docker build -t haproxy:v1 .
        ```
    + 启动容器测试：
        + 启动容器：
        ```
        [root@docker_2 haproxy]#docker run -it -d -p 80:80 haproxy:v1 
        ```  
        + 查看此时运行中的容器：  
            ![avagar](https://github.com/aNswerO/note/blob/master/18th-week/pic/docker%E5%88%B6%E4%BD%9C%E9%95%9C%E5%83%8F/%E8%BF%90%E8%A1%8C%E4%B8%AD%E7%9A%84%E5%AE%B9%E5%99%A8.png)  
        + 测试负载均衡（轮询）：  
            ![avagar](https://github.com/aNswerO/note/blob/master/18th-week/pic/docker%E5%88%B6%E4%BD%9C%E9%95%9C%E5%83%8F/%E6%B5%8B%E8%AF%95%E8%B4%9F%E8%BD%BD%E5%9D%87%E8%A1%A1.png)  
### 删除残留的无用镜像：
+ 残留镜像：  
    ![avagar](https://github.com/aNswerO/note/blob/master/18th-week/pic/docker%E5%88%B6%E4%BD%9C%E9%95%9C%E5%83%8F/%E6%AE%8B%E7%95%99%E9%95%9C%E5%83%8F.png)  
+ 删除：
    ```
    [root@docker_2 tomcat1]#docker rmi `docker images|grep none|awk '{print $3}'`
    ``` 
