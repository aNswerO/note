# haproxy基于acl实现动静分离：
## 动静分离的思路：
>将网站静态资源（HTML，JavaScript，CSS，img等文件）与后台应用分开部署，提高用户访问静态代码的速度，降低对后台应用访问。
## 实验主机：
+ web服务器1：10.0.1.1（nginx 1.12.2）

+ web服务器2：10.0.1.2（nginx 1.12.2）
+ 调度器：10.1.0.1（haproxy 1.5.18）
## 实验步骤：
1. 安装所需软件：
    + 调度器安装haproxy：
        ```
        yum install -y haproxy
        ```
    + 后端服务器安装nginx：
        ```
        yum install -y nginx
        ```
2. 修改调度器的haproxy配置文件，并重启使之生效：
    ```
    vim /etc/haproxy/haproxy.conf
    ```  
    ![avagar](https://github.com/aNswerO/note/blob/master/14th-week/pic/haproxy%E5%9F%BA%E4%BA%8Eacl%E6%96%87%E4%BB%B6%E5%90%8E%E7%BC%80%E5%AE%9E%E7%8E%B0%E5%8A%A8%E9%9D%99%E5%88%86%E7%A6%BB/haproxy%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6.png)  
    ```
    systemctl restart haproxy
    ```
3. 在web服务器上创建虚拟主机文件，并重启使之生效：
    + 10.0.1.1（用户访问动态文件调度到这台服务器）：
        ```
        vim /etc/nginx/conf.d/php.conf
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/14th-week/pic/haproxy%E5%9F%BA%E4%BA%8Eacl%E6%96%87%E4%BB%B6%E5%90%8E%E7%BC%80%E5%AE%9E%E7%8E%B0%E5%8A%A8%E9%9D%99%E5%88%86%E7%A6%BB/%E5%8A%A8.png)  
        >此服务器主页目录下只有一个phpinfo测试页
    + 10.0.1.2（用户访问静态文件调度到这台服务器）：
        ```
        vim /etc/nginx/conf.d/png.conf
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/14th-week/pic/haproxy%E5%9F%BA%E4%BA%8Eacl%E6%96%87%E4%BB%B6%E5%90%8E%E7%BC%80%E5%AE%9E%E7%8E%B0%E5%8A%A8%E9%9D%99%E5%88%86%E7%A6%BB/%E9%9D%99.png)  
        >此服务器主页目录下只有一个png文件
    + 重启两台主机的nginx服务使配置文件生效：
        ```
        systemctl restart nginx
        ```
4. 测试：  
![avagar](https://github.com/aNswerO/note/blob/master/14th-week/pic/haproxy%E5%9F%BA%E4%BA%8Eacl%E6%96%87%E4%BB%B6%E5%90%8E%E7%BC%80%E5%AE%9E%E7%8E%B0%E5%8A%A8%E9%9D%99%E5%88%86%E7%A6%BB/%E6%B5%8B%E8%AF%95%E5%8A%A8.png)  
![avagar](https://github.com/aNswerO/note/blob/master/14th-week/pic/haproxy%E5%9F%BA%E4%BA%8Eacl%E6%96%87%E4%BB%B6%E5%90%8E%E7%BC%80%E5%AE%9E%E7%8E%B0%E5%8A%A8%E9%9D%99%E5%88%86%E7%A6%BB/%E6%B5%8B%E8%AF%95%E9%9D%99.png)  
>因为两台服务器的主页目录下只有一个phpinfo测试页或png文件，所以访问到就说明动静分离成功
