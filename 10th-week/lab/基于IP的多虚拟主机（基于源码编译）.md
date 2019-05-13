# 基于IP的多虚拟主机：
1. 查看主配置文件的监听端口是否为默认的80：
    ```
    vim /app/http24/conf/httpd.conf
    ```  
    ![avagar](https://github.com/aNswerO/note/blob/master/10th-week/pic/%E5%9F%BA%E4%BA%8EIP%E7%9A%84%E5%A4%9A%E8%99%9A%E6%8B%9F%E4%B8%BB%E6%9C%BA/80.png)
2. 启用模块，并使对应的配置文件生效：
    ```
    vim /app/http24/conf/httpd.conf
    ```  
    ![avagar](https://github.com/aNswerO/note/blob/master/10th-week/pic/%E5%9F%BA%E4%BA%8E%E7%AB%AF%E5%8F%A3%E7%9A%84%E5%A4%9A%E8%99%9A%E6%8B%9F%E4%B8%BB%E6%9C%BA/%E5%90%AF%E7%94%A8%E6%A8%A1%E5%9D%97.png)  
    ![avagar](https://github.com/aNswerO/note/blob/master/10th-week/pic/%E5%9F%BA%E4%BA%8E%E7%AB%AF%E5%8F%A3%E7%9A%84%E5%A4%9A%E8%99%9A%E6%8B%9F%E4%B8%BB%E6%9C%BA/%E4%BD%BF%E8%99%9A%E6%8B%9F%E4%B8%BB%E6%9C%BA%E5%AF%B9%E5%BA%94%E7%9A%84%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6%E7%94%9F%E6%95%88.png)  
3. 创建如下目录，并在每个website目录下创建一个index.html文件：
    + 创建目录：  
    ![avagar](https://github.com/aNswerO/note/blob/master/10th-week/pic/%E5%9F%BA%E4%BA%8E%E7%AB%AF%E5%8F%A3%E7%9A%84%E5%A4%9A%E8%99%9A%E6%8B%9F%E4%B8%BB%E6%9C%BA/%E5%88%9B%E5%BB%BA%E7%9B%AE%E5%BD%95%E5%92%8C%E4%B8%BB%E9%A1%B5%E6%96%87%E4%BB%B6.png)  
    + index.html文件内容：  
        + website1/下index.html：  
            ![avagar](https://github.com/aNswerO/note/blob/master/10th-week/pic/%E5%9F%BA%E4%BA%8E%E7%AB%AF%E5%8F%A3%E7%9A%84%E5%A4%9A%E8%99%9A%E6%8B%9F%E4%B8%BB%E6%9C%BA/1.png)  
        + website2/下index.html：  
            ![avagar](https://github.com/aNswerO/note/blob/master/10th-week/pic/%E5%9F%BA%E4%BA%8E%E7%AB%AF%E5%8F%A3%E7%9A%84%E5%A4%9A%E8%99%9A%E6%8B%9F%E4%B8%BB%E6%9C%BA/2.png)  
        + website3/下index.html：  
            ![avagar](https://github.com/aNswerO/note/blob/master/10th-week/pic/%E5%9F%BA%E4%BA%8E%E7%AB%AF%E5%8F%A3%E7%9A%84%E5%A4%9A%E8%99%9A%E6%8B%9F%E4%B8%BB%E6%9C%BA/3.png)  
4. 修改对应的配置文件：
    ```
    vim httpd-vhosts.conf
    ```  
    ![avagar](https://github.com/aNswerO/note/blob/master/10th-week/pic/%E5%9F%BA%E4%BA%8EIP%E7%9A%84%E5%A4%9A%E8%99%9A%E6%8B%9F%E4%B8%BB%E6%9C%BA/%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6.png)  
5. 测试：  
    ![avagar](https://github.com/aNswerO/note/blob/master/10th-week/pic/%E5%9F%BA%E4%BA%8EIP%E7%9A%84%E5%A4%9A%E8%99%9A%E6%8B%9F%E4%B8%BB%E6%9C%BA/%E6%B5%8B%E8%AF%95.png)  
