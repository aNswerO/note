# 衡量网站访问量的指标：
+ IP（独立IP）：一天内来自相同客户端IP地址只计算一次

+ PV（访问量）：Page View；页面浏览量或点击量，用户每次刷新都会记录一次；PV反应的是浏览某网站的页面数，与来访者数量成正比，但并等同于来访者的数量，而是网站被访问的页面数量
+ UV（独立访客）：Unique Vister;访问网站的一台电脑记为一个访客,一天内相同的客户端只被计算一次;网站判断电脑的身份是通过访问来访电脑的**cookies**实现的，若只更换IP却没有清除cookies，再访问相同的网站，该网站统计的UV数时不会变的
+ QPS（request per second）：每秒请求数
    + 换算公式：
        ```
        QPS= PV* 页⾯衍⽣连接次数/ 统计时间（86400）
        并发连接数 =QPS * http平均响应时间
        ```
+ 峰值时间：每天80%的访问几种在20%的时间里，这20%时间为峰值时间
+ 峰值时间的QPS：
    ```
    (QPS)=( 总PV数 * 页⾯衍⽣连接次数）* 80% ) / ( 每天秒数 * 20% )
    ```
# http服务器的一次完整的http请求处理过程（在完成三次握手之后）：
1. 建立连接：接收或拒绝连接请求

2. 接收请求：接收客户端请求报文中对某资源的一次请求的过程
3. 处理请求：服务器对请求报文进行解析，并获取请求的资源及请求方法等相关信息；根据方法、资源、首部和可选的主题部分对请求进行处理
    + 请求行：用于描述客户端的请求方式，请求的资源名称以及使用的http协议的版本号

    + 请求头：用于描述客户端请求哪台主机，以及客户端的一些环境信息等
    + 请求正文：当使用POST、PUT等方法时，通常需要客户端向服务器传递数据，这些数据储存在请求正文中；请求正文将一个页面表单中的组件值通过键值对形式编码成格式化串，承载了多个请求参数的数据
4. 访问资源：
>服务器获取请求报文中请求的资源web服务器，向请求者提供对方请求的静态或动态运行后生成的资源
+ 资源存放于资源web服务器的本地文件系统特定的路径：DocRoot（httpd默认为/var/www/html）
    + web服务器资源路径映射方式：
        + DocRoot
        + alias
        + 虚拟主机DocRoot
        + 用户家目录DocRoot
5. 构建响应报文：
>一旦web服务器识别出了资源，就会执行请求方法中描述的动作并返回响应报文
+ 响应报文：
    + 响应行：
        + 报文协议和版本号
        + 响应状态码：用于表示服务器对请求的处理结果
        + 状态描述

    + 响应首部：用于描述服务器的基本信息，以及客户端如何处理数据
        + 通常包括：
            + Content-Type首部：返回内容的MIME类型
            + Content-Length首部：响应主体的长度，web服务器返回消息正文的长度
    + 响应主体（生成响应主体才会包含在响应报文中）
6. 发送响应报文：
    >服务器在此阶段要记录连接的状态，还要特别注意对持久连接的处理；因为对于持久连接来说，服务器发送了整条报文之后，连接可能仍保持打开状态，这种情况下服务器需要正确计算Content-Length首部，否则客户端无法得知响应合适结束
7. 记录日志：
    >事务结束时，服务器会在日志文件中添加一个条目，来记录自己执行的事务

# HTTP服务器应用：
## MPM（多路处理模块）工作模式：
+ prefork：多进程I/O模型；默认模型
    + 一个主进程：生成和回收n个子进程，创建套接字，不用来响应请求

    + 多个子进程：工作进程；每个子进程处理一个请求；初始会生成多个空闲进程来等待请求，最多不超过1024个
    + 优点：稳定
    + 缺点：占用内存大，请求处理慢，不适用于高并发场景
+ worker：复用的多进程I/O模型，多进程和多线程混合的模型
    + 一个主进程：生成多个子进程，不响应请求

    + 多个子进程：生成多个工作线程，每个线程响应一个请求
    + 优点：相比于prefork模式，占用内存较少，可同时处理更多请求
    + 缺点：使用长连接，某个工作线程会一直被占据，在无数据传输的情况下也会一直等到超时才会被释放；若有过多的线程处于这样的被占据的状态，也会导致在高并发场景下无服务线程可用（此问题在prefork模式下一样会发生）
+ event：事件驱动模型（woker模型的变种）
    + 一个主进程：生成多个子进程

    + 多个子进程：生成多个线程，其中有一个监控进程，由监控进程管理子进程下的keep-alive类型的多个工作线程，每个线程处理多个请求
        + 监控线程用于向工作线程分配任务并和客户端保持会话连接，超时后监控线程会删除此socket

        + 工作线程只用来处理用户的请求，处理完后将会话保持并交给监控进程，自己去处理新的请求，不再负责保持会话
    + 特点：只有在数据发送时才开始建立连接，连接请求才会触发工作线程，即使用了一个叫做TCP_DEFER_ACCEPT（延迟接受连接）的TCP选项，加了这个选项后，若客户端只进行TCP连接而不发送请求，则不会触发Accept操作，也就不会触发工作线程去工作，进行了简单的防攻击
    + 优点：单线程响应多请求，占据内存更少，高并发下表现优秀
    + 没有线程安全控制；即监控进程挂掉会使它所管理的所有工作线程无法正常工作

## httpd-2.2和httpd-2.4的区别：  
|htpd-2.2|httpd-2.4|
|---|---|
|event模式处于测试阶段|event模式可正常使用|
|将MPM工作模式编译成静态模块|MPM工作模式是通过DSO动态模块实现的|
|MPM工作模式在/etc/sysconfig/httpd文件中切换|MPM工作模式在/etc/httpd/conf.modules.d/00-mpm.conf文件中切换|
|mod_userdir.c模块配置文件默认存放在/etc/httpd/conf/httpd.conf文件中|mod_userdir.c模块配置文件默认存放在/etc/httpd/conf.d/userdir.conf文件中|
|基于FQDN的虚拟主机需要NameVirtualHost命令|基于FQDN的虚拟主机不需要NameVirtualHost命令|
|模板加载配置全写在/etc/httpd/conf/httpd.conf文件中|模板加载配置存放于/etc/httpd/conf.modules.d/下|
## httpd程序环境：
+ 相关文件：
    + 服务单元文件：/usr/lib/systemd/system/httpd.service

    + 配置文件：/etc/sysconfig/httpd
    + 主程序文件：
        + /usr/sbin/httpd
    + 主进程文件：
        + /etc/httpd/run/httpd.pid
    + 日志文件目录：
        + /var/log/httpd
            + access_log：访问日志
            + error_log：错误日志
    + 模块文件路径：
        + /etc/httpd/modules
        + /usr/lib64/httpd/modules
    + 默认站点网页文档根目录：
        + /var/www/html 
+ 服务控制和启动：
```shell
    systemctl enable|disable httpd.service
    #开机启动/不启动httpd

    systemctl {start|stop|restart} httpd.service
    #启动/停止/重启httpd
```
## httpd常见配置：（注意SELinux和防火墙的状态）
+ httpd配置文件组成：
    + Global Environment：全局配置
    + Main server configuration：主机配置（用于仅提供一个站点时）
    + virtual host：虚拟主机（用于提供多个站点时；主机配置和虚拟主机配置不能同时启用）
+ 配置格式：directive value
    + directive：不区分字符大小写
    + value：为路径时，是否区分大小写取决于文件系统
+ 修改监听的IP和PORT：
    ```shell
    Lisetn [IP:]PORT
    #IP可省略，省略表示本机所有IP
    #Listen指令至少一个，也可出现多次
    ```
+ 持久连接：
    ```shell
    KeepAlive On|Off
    #启用/关闭长连接

    KeepAliveTimeout 15
    #单位为秒
    ```
+ DSO（Dynamic Shared Object）：加载动态模块配置不需重启服务即可生效
    ```shell
    /etc/httpd/conf/httpd.conf
    Include conf.modules.d/*.conf

    LoadModule <mod_name> <mod_path>
    #模块路径可使用相对路径，相对于ServerRoot（默认为/etc/httpd）
    ```
    + 动态模块路径：/usr/lib64/httpd/modules/

    + 查看静态编译的模块：
        ```
        httpd -l
        ```
    + 查看静态编译和动态装载的模块：
        ```
        httpd -M
        ```
+ MPM（Multi-Processing Module）多路处理模块
    + 切换使用的MPM：在/etc/httpd/conf.module.d/00-mpm.conf中启用要启用的MPM相关的LoadModule指令即可
+ 定义Main server configuration中的页面路径：
    ```shell
    DocumentRoot "/PATH"
    #可以指定任意目录，但是需要在配置文件中进行授权，授权方法见下方站点访问控制
    ```
+ 定义站点主页面：
    ```
    DirectoryIndex index.html
    ```
+ 站点访问控制常见机制：
    >基于两种机制指明对**哪些资源**进行何种访问控制
    + 客户端来源地址
    + 用户账户
        + 文件系统路径：
            ```shell
            <Directory "/path">
            ...
            </Directory "/path">
            #对指定路径设定访问控制

            <File "/path/to/file">
            ...
            </File "/path/to/file">
            #对指定文件设定访问控制，使用通配符设定多个文件的访问控制

            <FileMatch "PATTERN">
            ...
            </FileMatch "PATTERN">
            #对指定文件设定访问控制，使用正则表达式设定多个文件的访问控制

            <Location “URL”>  
            ...
            <Location>
            #对指定URL设定访问控制

            <LocationMatch>
            ...
            </LocationMatch>
            #对指定URL设定访问控制，使用正则表达式设定多个URL的访问控制
            ```
+ 在<Driectory>中“基于源地址”实现访问控制：
    + Options：后跟一个或多个以空白字符分隔的选项列表；在选项前的“+”、“-”表示增加或删除指定选项
        + 常见选项：
            ```
            Indexes：指明的URL路径下不存在与定义的主页面资源相符的资源文件时，返回索引列表给用户
            FollowSymlinks：允许访问符号链接文件指向的源文件
            None：全部禁用
            All：全部允许
            ```
    + AllowOverride：与访问控制相关的哪些命令可以放在指定目录下的.htaccess（由AccessFileName指定）文件中，覆盖配置文件中的与访问控制相关的命令
        >.htaccess文件创建在哪个目录下，就需要配置文件中对应的<Directory>语句段中添加一行AllowOverride的语句做控制，如下：
        ```shell
        AllowOverride All
        #.htaccess文件中的所有指令都生效

        AllowOverride None
        #.htaccess文件中的所有指令都不生效

        AllowOverride Authconfig
        #.htaccess文件中的指令，只有AthuConfig生效
        ```
+ 基于IP的访问机制：
    >无明确授权的目录，默认为拒绝  
    Require all granted：允许所有主机访问  
    Require all denied：拒绝任何主机访问
    + 控制特定的IP访问：
        ```shell
        Require ip IPADDR
        #授权特定的IP访问

        Require not ip IPADDR
        #拒绝特定的IP访问 
        ```
    + 控制特定的主机访问：
        ```shell
        Require host HOSTNAME
        #授权特定的主机访问
        #HOSTNAME：
        #    FQDN：特定主机
        #    domain.tld：指定域名下的所有主机

        Require not host HOSTNAME
        #拒绝特定的主机访问
        ```
+ 在配置文件中设置访问控制：
    >在<RequieAll>语句段中添加语句，顺序由上至下逐条匹配，若匹配到一个语句，则立即执行，后面的语句不会生效
    + 两种写法：
        + 失败优先：
            ```shell
            <RequireAll>
            Require all granted    #授权所有主机访问
            Require not ip IPADDR    #拒绝特定IP访问
            </RequireAll>
            ```
        + 成功优先：
            ```shell
            <RequireAny>
            Require all denied    #拒绝所有主机访问
            Require ip IPADDR    #授权特定IP访问
            </RequireAny>
            ```
+ 日志设定：
    + 日志的类型：
        + 访问日志
        ```shell
        logFormat format strings
        ```

        + 错误日志（在配置文件中定义）
            ```shell
            ErrorLog /PATH/TO/ERROR_LOG
            LogLevel LEVEL
            #LogLevel可选值：debug, info, notice, warn,error, crit, alert, emerg
            ```
    + 定义日志格式：LogFormat format strings
        ```shell
        LogFormat "%h %l %u %{%F %T}t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" common

        # %h：客户端IP地址
        # %l：远程用户；通常为“-”，启用mod_ident时才有效
        # %u：验证远程用户；非登录访问时，为“-”
        # %t：服务器首到请求的时间
        # %r：请求报文的首行；记录了此次请求的方法、URL和协议版本
        # %>s：状态响应码
        # %b：响应报文的大小，单位是字节；不包括响应报文http首部
        # {referer}i：请求报文中首部“referer”的值；即从哪个页面中的超链接跳转到当前页面的
        # {user-agent}i：请求报文中首部“user-agent”中的值；即发出请求的应用程序
        ```
+ 设定默认字符集：
    ```shell
    AddDefaultCharset UTF-8
    #此为默认值
    ```
+ 定义路径别名：
    + 格式：Alias /URL/ "/PATH/"
    + 示例：
        ```shell
        Alias /data/ "/app/data"
        #当请求http://www.test.com/app/data/下的资源时，等同于请求http://www.test.com/data/下的资源
        ```
+ 基于用户的访问控制：
    + 认证质询：响应码为401，拒绝客户端请求，并要求客户端提供账号和密码

    + 认证（authorization）：客户端用户填入账号和密码后再次发送请求报文；认证通过时，服务器发送响应的资源
    + 两种认证方式：
        + basic：明文
        + digest：消息摘要认证
    + 安全域：需要用户认证成功后才能访问的路径
    + 用户的账号和密码：
        + 虚拟账号：仅用于访问某服务时用到的认证标识

        + 存储：文本文件、SQL数据库、ldap目录存储、nis等