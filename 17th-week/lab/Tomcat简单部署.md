# 部署Tomcat：
+ JSP WebApp目录结构：
    + 网站默认根目录：tomcat/webapps/ROOT/
    + 主页配置：一般指定为index.jsp或index.html

    + WEB-INF/：当前WebApp的私有资源路径，通常存储当前应用使用的web.xml和context.xml配置文件
    + META-INF/：类似于WEB-INF
    + classes/：类文件，当前WebApp需要的类
    + lib/：当前应用依赖的jar包
1. 安装Tomcat前需要安装JDK，下载地址：https://www.oracle.com/technetwork/java/javase/downloads/index.html
>下载rpm包，使用如下命令安装：
```
    yum install -y jdk-8u191-linux-x64.rpm
```

2. 添加环境变量：
    ```sh
        vim /etc/profile.d/jdk.sh 

        export JAVA_HOME=/usr/java/default
        export PATH=$JAVA_HOME/bin:$PATH
    ```
3. 安装Tomcat（下载地址：https://tomcat.apache.org/download-80.cgi）：
    ```
        tar xvf apache-tomcat-8.5.42.tar.gz -c /usr/local/
    ```
    ```
        ln -sv /usr/local/apache-tomcat-8.5.42/ /usr/local/tomcat
    ```
4. 添加环境变量：
    ```sh
        vim /etc/profile.d/tomcat.sh

        export TOMCAT_HOME=/usr/local/tomcat
        export PATH=$TOMCAT_HOME/bin:$PATH
    ```
## Tomcat的默认首页目录：
>/usr/local/tomcat/webapps/ROOT/为Tomcat的默认首页目录
+ /usr/local/tomcat/conf/web.xml：
    ```
        全局的欢迎页面文件列表，它定义了.jsp、.html、.htm文件的优先级，即这三种文件同时存在时，优先显示位于上面的文件
    ```
+ /usr/local/tomcat/webapps/ROOT/WEB-INF/web.xml：
    ```
        此文件下的定义仅对/usr/local/tomcat/webapps/ROOT/生效，若此文件中有配置，则此文件中的配置会覆盖/usr/local/tomcat/conf/web.xml中的配置
    ```
## webapp归档格式：
+ .war：WebApp打包
>应用开发测试后，通常打包为war格式，这种文件部署到了Tomcat的webapps目录下，可以自动展开，自动解包被定义在\<Host\>中的unpackWARs

+ .jar：EJB打包文件
+ .rar：资源适配器类打包文件
+ .ear：企业级WebApp打包
## 部署（deploy）：
+ 部署：
    ```
        将webapp的源文件放置在目标目录，通过web.xml和context.xml文件中配置的路径就可以访问该webapp，通过类加载器加载其特有的类和依赖的类到JVM上
    ```
    + 自动部署（auto deploy）：Tomcat发现多了一个应用，就自动它他加载并启动

    + 手动部署：
        + 冷部署：先停止Tomcat服务，将webapp放到指定目录下后，才去启动Tomcat

        + 热部署：Tomcat服务不停止，但需要依赖manager、ant脚本、tcd（tomcat client deployer）等工具
+ 反部署（undeploy）：
    ```
        停止webapp的运行，并从JVM上清除已加载的类，从Tomcat实例上卸掉webapp
    ```
+ 启动（start）：
    ```
        webapp能够访问
    ```
+ 停止（stop）：
    ```
    webapp不能访问，不能提供服务，但JVM不清除它
    ```
## jsp文件的转换过程：
```
    .jsp --> Tomcat转义 --> .java --> Tomcat调用JDK编译 --> .class --> 调用JDK运行
```
>转换后的文件存放在/usr/local/tomcat/work/Catalina/localhost/ROOT/org/apache/jsp/目录下，因为有这样的转换过程，所以第一次加载jsp页面会比较慢  
![avagar](https://github.com/aNswerO/note/blob/master/17th-week/pic/Tomcat/%E8%BD%AC%E6%8D%A2%E5%90%8E%E7%9A%84%E6%96%87%E4%BB%B6.png)  
## 配置文件/usr/local/tomcat/conf/server.xml
```xml
<?xml version="1.0" encoding="UTF-8"?>
<Server port="8005" shutdown="SHUTDOWN">
    <Service name="Catalina">
    <Connector port="8080" protocol="HTTP/1.1"
        connectionTimeout="20000"
        redirectPort="8443" />
    <Connector port="8009" protocol="AJP/1.3"     
        <Engine name="Catalina" defaultHost="localhost">
            <Host name="localhost" appBase="webapps"
            unpackWARs="true" autoDeploy="true">
            </Host>
        </Engine>
    </Service>
</Server>
```
>8005是Tomcat的管理端口，默认监听在127.0.0.1上，若接收到SHUTDOWN这个字符串后会关闭此server，可将SHUTDOWN改为一行随机生成的字符串
```xml
<GlobalNamingResources>
    <!-- Editable user database that can also be used by
    UserDatabaseRealm to authenticate users
    -->
    <Resource name="UserDatabase" auth="Container"
        type="org.apache.catalina.UserDatabase"
        description="User database that can be updated and saved"
        factory="org.apache.catalina.users.MemoryUserDatabaseFactory"
        pathname="conf/tomcat-users.xml" />
</GlobalNamingResources>
```
>这个配置段与用户认证相关，相关的配置文件是/usr/local/tomcat/conf/tomcat-users.xml
```xml
<Service name="Catalina">
```
>一般情况下一个server只配置一个service，name属性相当于该service的ID
```xml
<Connector port="8080" protocol="HTTP/1.1"
    connectionTimeout="20000"
    redirectPort="8443" />
```
>connector连接器配置；redirectport，重定向，若通过https协议访问，则自动转向此连接器，但由于Tomcat往往部署在内部，使用https协议性能较差，所以一般不启用https
```xml
<Engine name="Catalina" defaultHost="localhost">
```
>engine，引擎配置；defaulthost，缺省虚拟主机，指向内部定义的某虚拟主机，默认为localhost
```xml
<Host name="localhost" appBase="webapps" unpackWARs="true" autoDeploy="true">
```
>虚拟主机配置：  
name必须为主机名，用主机名来匹配  
appBase指定了当前主机的网页根目录，相对于CATALINA_HOME的相对路径，也可以使用绝对路径  
unpackWARs设定了是否自动解压war格式文件  
autoDeploy设定了是否开启热部署，即自动加载并运行应用
## 配置文件/usr/local/tomcat/conf/tomcat-users.xml：
```xml
<tomcat-users xmlns="http://tomcat.apache.org/xml"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://tomcat.apache.org/xml tomcat-users.xsd"
    version="1.0">
  <role rolename="manager-gui"/>
  <user username="qyh" password="qyh" roles="manager-gui"/>
</tomcat-users>
```
>访问manager页面时报403，所以需要添加用户，并在/usr/local/tomcat/webapps/manager/META-INF/context.xml文件中做修改

## 配置文件/usr/local/tomcat/webapps/manager/META-INF/context.xml：
```xml
<?xml version="1.0" encoding="UTF-8"?>
<Context antiResourceLocking="false" privileged="true" >
  <Valve className="org.apache.catalina.valves.RemoteAddrValve"
    allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1" />
  <Manager sessionAttributeValueClassNameFilter="java\.lang\.
(?:Boolean|Integer|Long|Number|String)|org\.apache\.catalina\.filters\.CsrfPreventionFilter\$Lru
Cache(?:\$1)?|java\.util\.(?:Linked)?HashMap"/>
</Context>
```
>将allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1" />改为allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1|172.20.6.\d+" />
+ 浏览器测试：
>修改配置文件后需要重启服务  
![avagar](https://github.com/aNswerO/note/blob/master/17th-week/pic/Tomcat/%E9%AA%8C%E8%AF%81manager%E9%A1%B5%E9%9D%A2.png)  
![avagar](https://github.com/aNswerO/note/blob/master/17th-week/pic/Tomcat/%E9%AA%8C%E8%AF%81manager%E9%A1%B5%E9%9D%A2_2.png)  
# 虚拟主机配置：
>配置一个虚拟主机，并将myapp部署到/data/webapps/下
+ 修改配置文件/usr/local/tomcat/conf/server.xml，在engine配置段下添加如下一行：
    ```
    <Host name="node1.qyh.com" appBase="/data/webapps/" unpackWARs="True" autoDeploy="false" />
    ```
    >因为使用了主机名，所以要在本机手动配置一个本地域名解析；由于使用windows的浏览器进行测试，所以要在windows也做本地域名解析
+ 创建目录，并添加项目：
    ```
    mkdir /data/webapps -pv
    ```
    ```sh
    cp -r  /usr/local/tomcat/webapps/projects/myapp/ /data/webapps/ROOT
    #将项目复制到/data/webapps/目录下，并将目录名设为ROOT
    ```
    + /data/webapps的目录结构：
    ```
    tree /data/webapps/
    /data/webapps/
    └── ROOT
        ├── classes
        ├── index.jsp
        ├── lib
        └── WEB-INF

    4 directories, 1 file
    ```
+ 重启Tomcat：
    ```
    catalina.sh stop

    catalina.sh start
    ```
+ 测试：  
![avagar](https://github.com/aNswerO/note/blob/master/17th-week/pic/Tomcat/%E8%99%9A%E6%8B%9F%E4%B8%BB%E6%9C%BA%E9%AA%8C%E8%AF%81.png)  
## 路径映射：
>通过context实现，应用独立配置，如单独配置应用日志、单独配置应用访问控制
+ 修改配置文件：
```xml
<Host name="node1.qyh.com" appBase="/data/webapps"
    unpackWARs="true" autoDeploy="true" >
  <Context path="/test" docBase="/data/test" reloadable="" />
</Host>
```
+ 创建目录，并将项目复制进来：
    ```
        mkdir /data/myapp1

        cp -r /usr/local/tomcat/webapps/projects/ /data/myapp1/
    ```
    + 目录结构：
    ```
    tree /data
    /data
    ├── myapp1
    │   ├── classes
    │   ├── index.jsp
    │   ├── lib
    │   └── WEB-INF
    ├── test -> /data/myapp1/
    └── webapps
        └── ROOT
            ├── classes
            ├── index.jsp
            ├── lib
            └── WEB-INF

    10 directories, 2 files
    ```
+ 创建软链接：
    ```sh
        cd /data/

        ln -sv /data/myapp1 /data/test
        #创建软链接是为了方便日后版本的升级和回滚
    ```
+ 测试：  
![avagar](https://github.com/aNswerO/note/blob/master/17th-week/pic/Tomcat/%E6%B5%8B%E8%AF%95context.png)  
