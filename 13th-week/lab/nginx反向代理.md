# nginx反向代理：
+ 实验主机：
    + nginx反向代理服务器1台：192.168.1.128

    + apache web服务器2台：192.168.1.136；192.168.1.137
    + 测试主机：192.168.1.159
+ 实验要求：
    ```
    将用户对域www.wp.com/backup的请求转发至后端服务器处理
    ```
1. 编辑主配置文件，在http设置块中添加如下配置：  
    ![avagar](https://github.com/aNswerO/note/blob/master/13th-week/pic/nginx%E5%8F%8D%E5%90%91%E4%BB%A3%E7%90%86/%E4%B8%BB%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6.png)  
2. 在虚拟主机的扩展配置文件/apps/nginx/conf/servers/wp_com.conf中添加如下配置：  
    ![avagar](https://github.com/aNswerO/note/blob/master/13th-week/pic/nginx%E5%8F%8D%E5%90%91%E4%BB%A3%E7%90%86/%E6%89%A9%E5%B1%95%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6.png)  
    >proxy_pass后的http://web:80的最后一个“/”：  
    若存在，等于访问http://web:80/index.html；  
    若不存在，等于访问http://web:80/backup/index.html，必须要后端服务器有backup目录才行
3. 测试：  
    ![avagar](https://github.com/aNswerO/note/blob/master/13th-week/pic/nginx%E5%8F%8D%E5%90%91%E4%BB%A3%E7%90%86/%E6%B5%8B%E8%AF%95.png)  
