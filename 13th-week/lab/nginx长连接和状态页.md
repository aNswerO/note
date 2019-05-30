# nginx长连接：
1. 在**主配置文件**中添加配置：  
    ![avagar](https://github.com/aNswerO/note/blob/master/13th-week/pic/%E9%95%BF%E8%BF%9E%E6%8E%A5/%E9%85%8D%E7%BD%AE.png)  
2. 测试：  
    ![avagar](https://github.com/aNswerO/note/blob/master/13th-week/pic/%E9%95%BF%E8%BF%9E%E6%8E%A5/%E6%B5%8B%E8%AF%95.png)  
    >由于keepalive_requests的值为2，所以在第二次访问后客户端就被动地断开了连接

# nginx状态页：
1. 查看编译时启用的模块，是否启用了http_stub_status_module（若未启用在添加了状态页相关的配置后重载会报错）：  
    ![avagar](https://github.com/aNswerO/note/blob/master/13th-week/pic/%E7%8A%B6%E6%80%81%E9%A1%B5/%E6%9F%A5%E7%9C%8B%E7%BC%96%E8%AF%91%E6%97%B6%E5%90%AF%E7%94%A8%E7%9A%84%E6%A8%A1%E5%9D%97.png)  
2. 编辑配置文件/apps/nginx/conf/servers/wp_com.conf以开启状态页：  
    ![avagar](https://github.com/aNswerO/note/blob/master/13th-week/pic/%E7%8A%B6%E6%80%81%E9%A1%B5/%E9%85%8D%E7%BD%AE.png)  
3. 测试：  
    ![avagar](https://github.com/aNswerO/note/blob/master/13th-week/pic/%E7%8A%B6%E6%80%81%E9%A1%B5/%E6%B5%8B%E8%AF%95.png)  
    >状态页用于输出nginx的基本状态信息
    + Active connections：当前处于活动状态的客户端连接数，包括连接等待的空连接；此处为1

    + accepts：统计总值；nginx自启动后已经接受的客户端请求的总数；此处为78
    + handled：统计总值；nginx自启动后已经处理完的客户端请求的总数，通常等于accepts，除非有因worker_connections限制等被拒绝的连接；此处为78
    + requests：统计总值；nginx自启动后客户端发来的请求总数；此处为86
    + Reading：当前状态；正在读取客户端请求报文首部的连接数；此处为0
    + Writing：当前状态；正在向客户端发送响应报文过程中的连接数；此处为1
    + Waiting：当前状态；正在等待客户端发出请求的空闲连接数；在开启了keep-alive的情况下，这个值等于active-（reading + writing）；此处为0
