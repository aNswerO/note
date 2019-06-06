# haproxy ACL实现域名匹配调度：
## 
## 实验主机：
+ 负载均衡服务器：192.168.1.136

+ 后端web服务器：
    + nginx：192.168.1.159（此服务器做域名匹配测试）

    + apache：192.168.1.20（此服务器为默认调度服务器）
1. 编辑haproxy的主配置文件，做如下配置，重载配置使之生效：
    ```
    vim /etc/haproxy/haproxy.conf
    ```  
    ![avagar](https://github.com/aNswerO/note/blob/master/14th-week/pic/ACL%E5%9F%9F%E5%90%8D%E6%8E%A7%E5%88%B6/haproxy%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6.png)  
    ```sh
    acl test_host hdr_dom(host) www.qyh.com    #根据接受到的报文，对报文头部的host信息进行匹配，若host的内容为www.qyh.com，则匹配成功；此acl的名字为test_host
    use_backend bak_1 if test_host    #若符合test_host这个acl的匹配条件，则调度到名为bak_1的backend中的主机
    default_backend default_host    #指定默认调度（即没有任何匹配时，调度到名为default_host的backend中的主机）

    backend bak_1
    backend default_host
    #指定名为bak_1和default_host的backend中的主机

    mode http    #由于需要对请求报文中的内容进行匹配，所以要使用七层负载均衡
    ```
    ```sh
    systemctl reload haproxy    #重载配置文件并开启新的进程
    ```
2. 后端服务器的配置：  
+ nginx：
    + 配置文件：  
    ![avagar](https://github.com/aNswerO/note/blob/master/14th-week/pic/ACL%E5%9F%9F%E5%90%8D%E6%8E%A7%E5%88%B6/%E5%9F%9F%E5%90%8D%E6%8E%A7%E5%88%B6%E8%B0%83%E5%BA%A6%E7%9A%84%E5%90%8E%E7%AB%AF%E6%9C%8D%E5%8A%A1%E5%99%A8%E9%85%8D%E7%BD%AE.png)  

    + 网页内容：  
    ![avagar](https://github.com/aNswerO/note/blob/master/14th-week/pic/ACL%E5%9F%9F%E5%90%8D%E6%8E%A7%E5%88%B6/%E7%BD%91%E9%A1%B5%E5%86%85%E5%AE%B9.png)  
+ apache：
    + 网页内容：  
    ![avagar](https://github.com/aNswerO/note/blob/master/14th-week/pic/ACL%E5%9F%9F%E5%90%8D%E6%8E%A7%E5%88%B6/%E9%BB%98%E8%AE%A4%E8%B0%83%E5%BA%A6%E6%9C%8D%E5%8A%A1%E5%99%A8%E7%BD%91%E9%A1%B5%E5%86%85%E5%AE%B9.png)  
3. 编辑Windows的本地解析文件并测试：
+ 添加本地解析记录：  
    ![avagar](https://github.com/aNswerO/note/blob/master/14th-week/pic/ACL%E5%9F%9F%E5%90%8D%E6%8E%A7%E5%88%B6/%E6%9C%AC%E5%9C%B0%E5%9F%9F%E5%90%8D%E8%A7%A3%E6%9E%90.png)  

+ 测试：  
    + 使用域名访问：  
    ![avagar](https://github.com/aNswerO/note/blob/master/14th-week/pic/ACL%E5%9F%9F%E5%90%8D%E6%8E%A7%E5%88%B6/%E6%B5%8B%E8%AF%95.png)  
    >被调度到nginx服务器

    + 使用IP地址访问：  
    ![avagar](https://github.com/aNswerO/note/blob/master/14th-week/pic/ACL%E5%9F%9F%E5%90%8D%E6%8E%A7%E5%88%B6/%E9%BB%98%E8%AE%A4%E8%B0%83%E5%BA%A6.png)  
    >被调度到默认服务器
