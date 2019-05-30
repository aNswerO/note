# nginx:
## 基础特性：
+ 模块化设计，较好的扩展性

+ 高可靠性
+ 支持热部署：不停机更新配置文件、升级版本、更换日志文件
+ 低内存消耗：10k个keep-alive连接模式下的非活动连接仅需2.5M内存
## nginx功能：
### 基本功能：
+ 静态资源的web服务器

+ http协议反向代理服务器
+ pop3/imap4协议反向代理服务器
+ FastCGI（LNMP），uWSGI（python）等协议
+ 模块化（非DSO）；如zip、SSL模块
### 和web服务相关的功能：
+ 虚拟主机（server）

+ 支持keep-alive和管道连接（利用一个连接做多次请求）
+ 访问日志（支持基于日志缓冲提高其性能）
+ url重写（rewrite）
+ 路径别名
+ 基于IP及用户的访问控制
+ 支持速率限制及并发量限制
+ 在线升级和重新配置而无需中断客户的工作进程
## nginx的组织模型：
>nginx是多进程组织模型，而且是由Master主进程和Worker工作进程组成
```
    工作进程是由主进程生成的  
    主进程使用fork()函数，在nginx服务器启动过程中主进程根据配置文件决定启动工作进程的数量，然后建立一张全局的工作表用于存放当前未退出的所有工作进程  
    主进程生成工作进程后会将新生成的工作进程加入到工作进程表中，并建立一个单向的管道并将其传递给工作进程（该管道与普通的管道不同，它是由主进程指向工作进程的单向管道，它包含了主进程向工作进程向工作进程发出的指令、工作进程ID、工作进程在工作进程表中的索引和必要的文件描述符等信息）
```
+ 主进程的功能：
    1. 读取nginx配置文件并验证其有效性和正确性

    2. 建立、绑定和关闭socket连接
    3. 按照配置生成、管理和结束工作进程、
    4. 接受外界指令，比如重启、升级及退出服务器等指令
    5. 不中断服务，实现平滑升级，重启服务并应用新的配置
    6. 升级失败进行回滚处理
    7. 开启日志文件，获取文件描述符
    8. 编译和处理perl脚本
+ 工作进程的功能：
    1. 接受并处理客户的请求

    2. 将请求送入各个功能模块进行处理
    3. IO调用，获取响应数据
    4. 与后端服务器通信，接收后端服务器的处理结果
    5. 缓存数据，访问缓存索引，查询和调用缓存数据
    6. 发送请求结果，响应客户的请求
    7. 接受主进程指令，比如重启、升级和退出等
## 进程间通信：
+ 主进程和工作进程间通信：
    ```
        主进程通过信号机制与外界进行通信，当接收到需要处理的信号时，它通过管道向相关的工作进程发送正确的指令，每个工作进程都有能力捕获管道中的可读事件，当管道中有可读事件的时候，工作进程就会从管道中读取并解析指令，然后采取响应的执行动作，这样就完成了主进程和工作进程的交互
    ```
+ 工作进程间的通信：
    ```
        工作进程间的通信原理基本与主进程和工作进程间的通信是一样的，只要工作进程之间能够获取彼此的信息，那么建立管道就可以进行通信  
        但是由于工作进程之间时完全隔离的，所以一个工作进程想要获取另一个工作进程的信息就只能通过主进程来设置  
        为了实现工作进程间的交互，主进程在生成工作进程之后，会在工作进程表中进行遍历，将该新进程的ID以及针对该进程建立的管道句柄传递给工作进程中的其他进程，为工作进程间的通信做准备  
        当工作进程1向工作进程2发送指令时，首先主进程要找到工作进程2的ID，然后将正确的指令写入指向进程2的管道，工作进程2捕获到管道中的事件后，对指令进行解析并进行相关操作，这样就完成了工作进程间的通信
    ```
## nginx的模块：
+ 核心模块：
    ```
        是nginx服务器正常运行必不可少的模块，提供错误日志管理、配置文件解析、事件驱动机制、进程管理等核心功能
    ```
+ 标准http模块：
    ```
        提供http协议解析的相关功能，比如端口设置、网页编码设置、http响应头设置等
    ```
+ 可选http模块：
    ```
        主要用于扩展标准的http功能，让nginx能处理一些特殊的服务，比如flash多媒体传输、解析GeoIP请求、网络传输压缩、安全协议SSL支持等
    ```
+ 邮件服务模块：
    ```
        主要用于支持nginx的邮件服务，包括对POP3协议、IMAP协议和SMTP协议的支持
    ```
+ 第三方模块：
    ```
        是为了扩展nginx服务器应用，完成开发者自定义功能，比如Json支持、Lua支持等
    ```
## nginx的配置文件：
### 配置文件的组成部分：
+ 主配置文件：nginx.conf

+ 子配置文件：conf.d/*.conf（在配置文件中使用include指定）
>指令必须以分号结尾  
支持使用配置变量：内建变量（由nginx模块引入，可直接引用）、自定义变量（由用户使用set命令定义：set VARIABLE_NAME VALUE）、引用变量（$VARIABLE_NAME）
### 主配置文件：
+ 全局配置段：
    ```
        对全局生效；主要设置nginx的启动用户和组、启动的工作进程数量、工作模式、nginx的PID路径、日志路径
    ```

+ event设置块：
    ```
        主要影响nginx服务器与用户的网络连接，比如是否允许同时接受多个网络连接、使用哪种事件驱动模型处理请求，每个工作进程可以同时支持的最大连接数，是否开启对多工作进程下的网络连接进行序列化等
    ```
+ http设置块：
    ```
        http设置块是nginx服务器配置中的重要部分；缓存代理和日志格式定义等绝大多数功能和第三方模块都可以在这里设置；http设置块可以包含多个server块
    ```
    + server设置块：
        ```
            设置一个虚拟主机，可以包含自己的全局块，如本虚拟主机监听的端口、名称和IP配置；多个server可以使用同一个端口
        ```
    + location设置块：
        ```
            location其实是server的一个指令，主要是基于nginx接收到的请求字符串，对用户请求的URL进行匹配，并对特定的指令进行处理，包括地址重定向、数据缓存和应答控制等功能
        ```
        >同时存在多个location时的优先级：=，^~，~和~*，/
        + root与alias：
            + root：指定web的家目录，在定义location的时候，文件的绝对路径等于root+location

            + alias：定义路径别名，把访问的路径重新定义到指定的路径
+ 导入其他路径的配置文件：
    ```
        include /PATH/TO/*.conf
    ```
#### 主配置文件详解：
+ 全局配置：
    ```sh
        user  nginx nginx;  #启动nginx工作进程的用户和组
        worker_process [number | auto];  #启动nginx工作进程的数量
        worker_cpu_affinity XXXX XXXX;  #将nginx工作进程绑定到指定的CPU核心；默认nginx是不进行绑定的（绑定不意味着当前nginx进程独占一个核心，但可以保证此进程不会工作在其他核心上，这就极大减少了nginx的工作进程在不同CPU核心上的来回跳转，减少了CPU对进程的资源分配与回收以及内存管理等，可以有效提升nginx服务器的性能）
        error_log FILE [debug | info | notice | warn | error | crit | alert | emerg];  #错误日志记录配置
        pid  /apps/nginx/logs/nginx.pid;  #pid文件保存路径
        worker_priority NUM;  #工作进程优先级：-20~19
        worker_rlimit_nofile XXX;  #这个数字包括nginx的所有连接（如与代理服务器间的连接等），而不仅仅是与客户端的连接，另一个考虑因素是实际的并发连接数不能超过系统级别最大打开文件数的限制
        daemon off;  #前台运行nginx服务用于测试
        master_process off|on;  #是否开启nginx的master-worker工作模式
        events {
            worker_connections 65535;  #设置单个nginx工作进程可以接受的最大并发；作为web服务器时最大并发数为worker_connections*worker_processes；作为反向代理服务器时最大并发数为（worker_connections*worker_processes）/2
            use epoll;  #使用epoll事件驱动；nginx支持select、poll、epoll事件驱动，只能在events模块中设置
            accept_mupex on;  #优化同一时刻只有一个请求而避免多个睡眠进程被唤醒（惊群）的设置，on为防止同时被唤醒，默认为off
            mutli_accept on;  #nginx服务器的每个工作进程可以同时接受多个新的网络连接，但是需要在配置文件中配置；此指令默认为off
        }
    ```
+ http设置块：
    ```sh
        include  mime.types;  #导入支持的文件类型
        default_type  application/octet-stream;  #设置默认的类型，会提示下载不匹配的类型文件

        #日志配置部分：
        log_format main '$remote_addr - $remote_user [$time_local] "$request"'
                        '$status $body_bytes_sent "$http_referer"'
                        '"$http_user_agent" "$http_x_forwarded_for"';
        access_log  /var/logs/nginx/access.log  main;  #main为日志格式的名字，logs/access.log为日志文件的路径

        #自定义优化参数：
        sendfile  on;  #指定是否使用sendfile系统调用（sendfile系统调用在两个文件描述符之间传递数据，此过程完全在内核中操作，从而避免了数据在内核缓冲区和用户缓冲区之间的拷贝，操作效率高，被称为零拷贝）来传输文件
        tcp_nopush  on;  #在开启了sendfile的情况下，合并请求后同一发送给客户端
        tcp_nodelay  off;  #在开启了keepalived模式下的连接是否启用TCP_NODELAY选项，当为off时，延迟发送，合并多个请求后再发送；默认为on，不延迟发送，立即发送用户相应报文。
        keepalive_timeout  65;  #设置会话保持时间
        gzip  on;  #开启文件压缩
    ```
+ server设置块：
    ```sh
        listen  80;  #设置监听地址和端口
        server_name  localhost;  #设置server name；可以用空格分开写多个，并支持正则表达式
        charset  koi8-r;  #设置编码格式，默认是俄语；可改为utf-8
        access_log  /var/logs/nginx/;access.log  main;
        location  / {
            root  html;
            index  index.html index.htm;
        }

        #定义错误页面：
        error_page  404  /404.html;
        error_page  500 502 503 504  50x.html;
        location  /50x.html {
            root  html;
        }

        #以fastcgi方式转发php请求到指定web服务器：
        location  ~ \.php$ {
            proxy_pass  http://127.0.0.1;
        }

        #以fastcgi方式转发php请求给php处理
        location  ~ \.php$ {
            root  html;
            fastcgi_pass  127.0.0.1:9000;
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
            include  fastcgi_parmas;
        }

    ```