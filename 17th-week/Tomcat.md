# Tomcat：
## Tomcat是什么：
```
    Tomcat服务器是一个轻量级应用服务器，是开发和调试JSP（Java Server Pages，一种使软件开发者可以响应客户端请求，而动态生成 HTML、XML 或其他格式文档的Web网页的技术标准，本质是一个简化的servlet）程序的首选
```
## Tomcat和Apache的区别：
1. Apache是web服务器，用作静态解析，如html；Tomcat是java应用服务器，用作动态解析，如JSP,PHP

2. Tomcat只是一个servlet**容器**，可认为是Apache的扩展，但可以独立于Apache运行
## Tomcat：
### Tomcat的目录结构及说明：
|目录|说明|
|--|--|
|bin|服务启停相关|
|conf|存放配置文件|
|lib|存放库|
|logs|存放日志|
|webapps|应用部署目录|
|work|jsp编译后的结果文件|
### Tomcat配置文件：

|配置文件|说明|
|--|--|
|server.xml|主配置文件|
|web.xml|每个webapp只有经**部署**后才能被访问，它的**部署方式**通常由**web.xml**进行定义，其存放位置为WEB-INF/目录；此配置文件为所有的webapps提供默认部署相关的配置|
|context.xml|每个webapp都可以专用的配置文件|context.xml，其存放位置为WEB-INF/目录；此文件为所有的webapp提供默认配置|
|tomcat-users.xml|用户认证的账号和密码文件|
|catalina.policy|当使用-security选项启动Tomcat时，用于为Tomcat设置安全策略|
|catalina.properties|Java属性的定义文件，用于设定类加载器路径，以及一些与JVM调优相关的参数|
|logging.properties|日志系统相关的配置|
## Tomcat的组件分类：
+ 顶级组件：
    ```
        Server，代表整个Tomcat容器
    ```
+ 服务类组件：
    ```
        Service，组织Engine和Connecto，里面只能包含一个Engine
    ```
+ 连接器组件：
    ```
        Connector，有HTTP、HTTPS、AJP协议的连接器
    ```
    >AJP（Apache Jserv protocol）是一种基于TCP的二进制通讯协议
+ 容器类组件：
    ```
        Engine、Host、Context都是容器类组件，可嵌入其他组件，内部配置如何运行应用程序
    ```
+ 内嵌类组件：
    ```
        可嵌入到其他组件内，如valve、logger、realm、loader、manager等
    ```
+ 集群类组件：
    ```
        listener、cluster
    ```
## Tomcat的内部组成：  
![avagar]()  
|名称|说明|
|--|--|
|Server|Tomcat运行的实例进程|
|Connector|负责客户端的HTTP、HTTPS、AJP等协议的连接，一个Connector只属于某一个Engine|
|Service|用来组织Engine和Connector的关系|
|Engine|响应并处理用户请求，一个Engine上可绑定多个Connector|
|Host|虚拟主机|
|Context|应用的上下文，配置路径映射PATH-->DIRECTORY|
+ Tomcat启动一个Server进程；可以启动多个server，但一般只启动一个

+ 创建一个Service提供服务；可创建多个Service，但一般只创建一个
+ 可以为Server提供多个Connector，这些Connector使用了不同的协议，绑定了不同的端口，作用就是处理来自不同客户端的不同的连接请求或响应
+ Service内部还定义了Engine，Engine才是真正的处理请求的入口，其内部定义多个Host
    + Engine对请求头做分析，将请求发送给相应的Host

    + 在Engine做出分析后，若没有匹配，数据就发往Engine上的defaultHost（缺省虚拟主机）
    + Engine上的缺省虚拟主机可以修改
+ Host定义虚拟主机，虚拟主机有name名称，通过名称匹配
+ Context定义应用程序单独的路径映射和配置
## 一次请求的响应过程：
>用户的请求为http://localhost:8080/test/index.jsp
1. 浏览器端的请求被发送到服务端端口8080，Tomcat进程监听在此端口，通过侦听的HTTP/1.1 Connector获得此请求

2. Connector把该请求交给它所在的Service的Engine来处理，并等待Engine的响应
3. Engine获得请求：localhost:8080/test/index.jsp，交给它匹配的Host（localhost）处理（哪怕没有匹配到，也会交给localhost处理，因为localhost被定义为该Engine的默认主机）
4. localhost获得请求/test/index.jsp，匹配它拥有的所有Context
5. Host匹配到的路径为/test的Context
6. path=/test的Context获得请求/index.jsp，在它的mapping table中寻找对应的servlet
7. Context匹配到URL PATERN为*.jsp的servlet，对应于JspServlet类构造HTTPServletRequest对象和HTTPServletResponse对象，作为调用JspServlet的doGet或doPost方法
8. Context把执行完了之后的HttpServletResponse对象返回给Host
9. Host把HttpServletResponse对象返回给Engine
10. Engine把HttpServletResponse对象返回给Connector
11. Connector把HttpServletResponse对象返回给浏览器端
