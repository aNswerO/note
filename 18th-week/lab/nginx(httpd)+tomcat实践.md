# nginx + tomcat实践：
+ 规划：

|主机角色|主机名|IP|
|--|--|--|
|负载均衡器|LB|192.168.6.10|
|后端web服务器_1|backend_1|192.168.6.20|
## 环境准备：
+ 两台主机的本机域名解析：
    ```
        vim /etc/hosts

        192.168.6.10 lb.qyh.com
        192.168.6.20 backend1.qyh.com
    ```
+ windows的本地域名解析：
    >文件位置：C:\Windows\System32\drivers\etc\hosts
    ```
        192.168.6.10 lb.qyh.com
        192.168.6.20 backend1.qyh.com
    ```
+ 在负载均衡器安装nginx：
    ```sh
        wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
        #准备epel源
    ```
    ```sh
        yum install -y nginx
        #安装nginx
    ```
+ 在后端服务器安装JDK和Tomcat：
    + 安装JDK：
    >JDK下载地址：https://www.oracle.com/technetwork/java/javase/downloads/index.html
    ```
        [root@backend_1 ~]#yum install -y jdk-8u191-linux-x64.rpm
    ```
    + 添加JAVA环境变量：
    ```
        [root@backend_1 ~]#vim /etc/profile.d/jdk.sh

        export JAVA_HOME=/usr/java/
        export PATH=$JAVA_HOME/bin:$PATH
    ```  
    + 安装Tomcat：
    >Tomcat下载地址：https://tomcat.apache.org/download-80.cgi
    ```
        [root@backend_1 ~]#tar -xvf apache-tomcat-8.5.42.tar.gz -c /usr/local/

        [root@backend_1 ~]#ln -sv /usr/local/apache-tomcat-8.5.42/ /usr/local/tomcat
    ```
    + 添加环境变量：
    ```
        [root@backend_1 ~]#vim /etc/profile.d/tomcat.sh

        export TOMCAT_HOME=/usr/local/tomcat/
        export PATH=$TOMCAT_HOME/bin:$PATH
    ```
## nginx + tomcat实现动静分离：
+ 负载均衡器：
    + 编辑nginx配置文件，修改location设置段内容为：
        >当请求的资源不是jsp文件时，由本机的nginx处理；当请求资源为jsp文件时，则交由后端的tomcat服务器backend_1处理
        ```
            [root@lb ROOT]#vim /etc/nginx/nginx.conf

            location / {
                root /data/webapps/ROOT;
                index index.html;
            }

            location ~* \.jsp$ {
                    proxy_pass http://backend1.qyh.com:8080;
            }
        ```
    + 在负载均衡器创建如下目录，并创建一个html文件：
        ```
            [root@lb ~]#mkdir -pv /data/webapps/ROOT
        ```
        ```
            [root@lb ~]#vim index.html

            <h1>LB</h1>
        ```
+ 后端服务器（backend_1）：
    + 启动tomcat：
        ```
            [root@backend_1 ROOT]#catalina.sh start
        ```
+ 测试动静分离：  
    ![avagar](https://github.com/aNswerO/note/blob/master/18th-week/pic/tomcat%E5%AE%9E%E8%B7%B5/%E5%8A%A8%E9%9D%99%E5%88%86%E7%A6%BB.%E6%B5%8B%E8%AF%95_1.png)  
    ![avagar](https://github.com/aNswerO/note/blob/master/18th-week/pic/tomcat%E5%AE%9E%E8%B7%B5/%E5%8A%A8%E9%9D%99%E5%88%86%E7%A6%BB%E6%B5%8B%E8%AF%95_2.png)  
    >由于为了测试方便，只添加了请求资源为jsp文件的转发，还有文件访问不到，所以不能正确渲染

## HostManager虚拟主机管理：
+ 编辑tomcat-users.xml文件，在tomcat-users设置段下添加以下内容：
    ```
    [root@backend_1 tomcat]#vim /usr/local/tomcat/conf/tomcat-users.xml

    <role rolename="manager-gui"/>
        <role rolename="admin-user"/>
        <user username="qyh" password="qyh" roles="manager-gui,admin-gui"/>
    ```
+ 编辑文件，修改allow的值为以下内容：
    ```
    [root@backend_1 tomcat]#vim /usr/local/tomcat/webapps/host-manager/META-INF/context.xml 

    allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1|192\.168\.6\.\d+" />
    ```  
![avagar](https://github.com/aNswerO/note/blob/master/18th-week/pic/tomcat%E5%AE%9E%E8%B7%B5/%E8%99%9A%E6%8B%9F%E4%B8%BB%E6%9C%BAweb%E7%AE%A1%E7%90%86%E7%95%8C%E9%9D%A2.png)  
# httpd + tomcat实践：
## proxy_httpd_module模块代理：
>httpd与tomcat部署在同一台主机
+ 安装httpd：
    ```
        [root@backend_1 tomcat]#yum install -y httpd
    ```
+ proxy_httpd_module模块代理配置：
    ```
        [root@backend_1 tomcat]#vim /etc/httpd/conf.d/http-tomcat.conf 

        <VirtualHost *:80>
        ServerName      backend1.qyh.com
        ProxyRequests   Off
        ProxyVia        On
        ProxyPreserveHost       On
        ProxyPass       /       http://127.0.0.1:8080/
        ProxyPassReverse        /       http://127.0.0.1:8080/
        </VirtualHost>
    ```
+ 检查httpd是否有语法错误：
    ```
        [root@backend_1 tomcat]#httpd -t
        Syntax OK
    ```
+ 重启httpd：
    ```
        [root@backend_1 tomcat]#systemctl restart httpd
    ```
+ 测试：  
![avagar](https://github.com/aNswerO/note/blob/master/18th-week/pic/tomcat%E5%AE%9E%E8%B7%B5/%E6%B5%8B%E8%AF%95httpd.png)  
## proxy_ajp_module模块代理：
>httpd和tomcat部署在同一主机
+ proxy_ajp_module模块代理配置：
    ```
        [root@backend_1 httpd]#vim /etc/httpd/conf.d/http-tomcat.conf 
        <VirtualHost *:80>
        ServerName      backend1.qyh.com
        ProxyRequests   Off
        ProxyVia        On
        ProxyPreserveHost       On
        ProxyPass       /       ajp://127.0.0.1:8009/
        </VirtualHost>
    ```
+ 检查语法：
    ```
        [root@backend_1 httpd]#httpd -t
    ```
+ 重启httpd：
    ```
        [root@backend_1 httpd]#systemctl restart httpd
    ```
+ 测试：  
![avagar](https://github.com/aNswerO/note/blob/master/18th-week/pic/tomcat%E5%AE%9E%E8%B7%B5/ajp.png)  
