# HAProxy状态页：
+ 编辑haproxy的配置文件：
    ```
    vim /etc/haproxy/haproxy.cfg
    ```  
    ```sh
    listen stats
        bind :9009    #监听的端口号
        stats enable    #启用状态页
        stats uri /haproxy-status    #访问的uri
        stats realm HAProxy_stat_page    #账户认证时的提示信息
        stats auth admin:centos    #认证时使用的账号和密码
        stats refresh 30s    #自动刷新的时间间隔
        stats admin if TRUE    #启用状态页的管理功能，即可通过web管理节点
    ```
+ 重启服务并测试：
    ```
    systemctl restart haproxy
    ```  
    ![avagar](https://github.com/aNswerO/note/blob/master/14th-week/pic/%E7%8A%B6%E6%80%81%E9%A1%B5%E3%80%81%E6%97%A5%E5%BF%97%E5%92%8C%E5%8E%8B%E7%BC%A9/%E7%8A%B6%E6%80%81%E9%A1%B5.png)  
+ 页面参数解释：
    + Queue:
        ```sh
        Cur    #当前的队列请求数量
        Max    #最大的队列请求数量
        Limit    #队列限制数量
        ```
    + Sessions：
        ```sh
        Cur    #当前的会话
        Max    #最大会话
        Limit    #会话限制
        Total    #总会话量
        LbTot    #选中一台服务器所用的总时间
        ```
    + Byte：
        ```sh
        In    #网络的字节数输入总量
        Out    #网络的字节数输出总量
        ```
    + Denied：
        ```sh
        Req    #拒绝请求量
        Resp    #拒绝回应量
        ```
    + Errors：
        ```sh
        Req    #错误请求
        Conn    #错误连接
        Resp    #错误回应
        ```
    + Warning：
        ```sh
        Retr    #重新尝试
        Conn    #再次发送
        ```
    + Server：
        ```sh
        Status    #包括后端服务器活动（up）和后端服务器挂掉（down）两种状态
        LastChk    #持续检查后端服务器的时间
        Wght    #权重
        Act    #活动连接数量
        Bck    #备份的服务器数量
        Down    #后端服务器连接后都是down的数量
        Downtime    #总的downtime
        Throttle    #设备变热状态
        ```

# HAProxy日志：
## 开启HAProxy日志：
+ 编辑HAProxy的配置文件：
    ```
    vim /etc/haproxy/haproxy.conf
    ```
    ```sh
    log         127.0.0.1 local2    #配置在global设置块下
    ```
    ```sh
    log         global    #配置在defaults设置块下
    ```
+ 编辑rsyslog的配置文件：
    ```
    vim /etc/rsyslog.conf 
    ```
    ```sh
    $ModLoad imudp
    $UDPServerRun 514
    #取消这两行的注释
    ```
    ```sh
    local2.*                                                /var/log/haproxy.log
    #添加此行
    ```
+ 重启haproxy和rsyslog：
    ```
    systemctl restart rsyslog haproxy
    ```
+ 查看日志：  
    ![avagar](https://github.com/aNswerO/note/blob/master/14th-week/pic/%E7%8A%B6%E6%80%81%E9%A1%B5%E3%80%81%E6%97%A5%E5%BF%97%E5%92%8C%E5%8E%8B%E7%BC%A9/%E6%B5%8B%E8%AF%95%E6%97%A5%E5%BF%97.png)  
## 将特定信息记录在日志中：
>配置在配置文件的listen设置块中
+ 相关配置：
    ```sh
    capture cookie <NAME> len <LENGTH>    #捕获请求和响应报文中的cookie并记录日志
    capture request header <NAME> len <LENGTH>    #捕获请求报文中指定长度的首部内容并记录日志
    capture response header <NAME> len <LENGTH>    #捕获响应报文中指定长度的首部内容并记录日志
    ```
# HAProxy的压缩功能：
>配置在defaults或listen设置块下
+ 相关配置：
    ```sh
    compression algo    #启用http协议中的压缩机制，并指定算法
    compression type    #压缩的文件类型
    ```
+ 示例：
    ```
    compression algo gzip
    compression type compression type text/plain text/html text/css text/xml image/png text/javascript application/javascript
    ```  
+ 测试：  
    ![avagar](https://github.com/aNswerO/note/blob/master/14th-week/pic/%E7%8A%B6%E6%80%81%E9%A1%B5%E3%80%81%E6%97%A5%E5%BF%97%E5%92%8C%E5%8E%8B%E7%BC%A9/%E6%B5%8B%E8%AF%95%E5%8E%8B%E7%BC%A9.png)  
