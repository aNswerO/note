# haproxy实现基于cookie的会话保持：
## 实验主机：
+ HAProxy负载均衡器：192.168.1.136
+ nginx web服务器：192.168.1.159
+ windows做测试主机
## cookie配置相关：
```sh
cookie <value>    #为当前server指定cookie值，以实现会话保持

cookie <name> [ rewrite | insert | prefix ] [ indirect ] [ nocache ]    
#<name>：cookie名称
#   rewrite：重写
#   insert：插入
#   prefix：前缀
#   nocache：当client和haproxy之间有缓存时，不缓存cookie
```
## 实验步骤：
+ 在haproxy负载均衡器上做如下配置：
    ```
    vim /etc/haproxy/haproxy.cnf
    ```  
    ![avagar](https://github.com/aNswerO/note/blob/master/14th-week/pic/cookie%E4%BC%9A%E8%AF%9D%E4%BF%9D%E6%8C%81%E5%92%8CIP%E9%80%8F%E4%BC%A0/cookie%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6.png)  

+ 测试：  
    ![avagar](https://github.com/aNswerO/note/blob/master/14th-week/pic/cookie%E4%BC%9A%E8%AF%9D%E4%BF%9D%E6%8C%81%E5%92%8CIP%E9%80%8F%E4%BC%A0/cookie%E4%BC%9A%E8%AF%9D%E4%BF%9D%E6%8C%81.png)  

# IP透传：
>使后端服务器获取到用户的IP地址
## 实验主机：
+ HAProxy负载均衡器：192.168.1.136
+ nginx web服务器：192.168.1.159
+ windows做测试主机
## 四层负载均衡的IP透传：
### 实验步骤：
+ 在HAProxy负载均衡器上做如下配置：
    ```
    vim /etc/haproxy/haproxy.cnf
    ```  
    ![avagar](https://github.com/aNswerO/note/blob/master/14th-week/pic/cookie%E4%BC%9A%E8%AF%9D%E4%BF%9D%E6%8C%81%E5%92%8CIP%E9%80%8F%E4%BC%A0/%E5%9B%9B%E5%B1%82%E9%80%8F%E4%BC%A0%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6.png)  
+ 修改后端nginx服务器的配置文件：
    ```sh
    vim /apps/nginx/conf/nginx.conf
    #将listen   80;这行改为--> listen  80 proxy_protocol;
    ```
+ 修改日志的记录格式：
    ```sh
    vim /apps/nginx/conf/nginx.conf

    log_format access_json '{"@timestamp":"$time_iso8601",'
        '"host":"$server_addr",'
        '"clientip":"$remote_addr",'
        '"size":$body_bytes_sent,'
        '"responsetime":$request_time,'
        '"upstreamtime":"$upstream_response_time",'
        '"upstreamhost":"$upstream_addr",'
        '"http_host":"$host",'
        '"uri":"$uri",'
        '"domain":"$host",'
        '"xff":"$http_x_forwarded_for",'    #这个变量的值为七层负载均衡下获取到的客户端IP
        '"referer":"$http_referer",'
        '"tcp_xff":"$proxy_protocol_addr",'    #这个变量的值为四层负载均衡下获取到的客户端IP
        '"http_user_agent":"$http_user_agent",'
        '"status":"$status"}';
    ```
+ 重启haproxy和nginx并测试：
    ```
    systemctl restart haproxy
    nginx -s reload
    ```  
    ![avagar](https://github.com/aNswerO/note/blob/master/14th-week/pic/cookie%E4%BC%9A%E8%AF%9D%E4%BF%9D%E6%8C%81%E5%92%8CIP%E9%80%8F%E4%BC%A0/%E5%9B%9B%E5%B1%82IP%E9%80%8F%E4%BC%A0.png)  
## 七层负载均衡的IP透传：
### 实验步骤：
+ 在HAProxy负载均衡器上做如下配置：
    ```
    vim /etc/haproxy/haproxy.cnf
    ```  
    ![avagar](https://github.com/aNswerO/note/blob/master/14th-week/pic/cookie%E4%BC%9A%E8%AF%9D%E4%BF%9D%E6%8C%81%E5%92%8CIP%E9%80%8F%E4%BC%A0/%E4%B8%83%E5%B1%82%E9%80%8F%E4%BC%A0%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6.png)  

+ 修改日志格式同上
+ 重启haproxy和nginx并测试：
    ```
    systemctl restart haproxy
    nginx -s reload
    ```  
    ![avagar](https://github.com/aNswerO/note/blob/master/14th-week/pic/cookie%E4%BC%9A%E8%AF%9D%E4%BF%9D%E6%8C%81%E5%92%8CIP%E9%80%8F%E4%BC%A0/IP%E9%80%8F%E4%BC%A0.png)  
