# nginx账户认证：
1. 安装所需工具：
    ```
    yum install -y httpd-tools
    ```
2. 生成保存有账户以及账户密码的文件：
    ```
    htpasswd -cbm htpasswd -cbm /apps/nginx/conf/.htpasswd jack 123123
    ```
3. 在配置文件中添加账户认证的配置：  
    ![avagar](https://github.com/aNswerO/note/blob/master/13th-week/pic/nginx%E8%B4%A6%E5%8F%B7%E8%AE%A4%E8%AF%81/%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6.png)  
4. 重载配置文件：
    ```
    nginx -s reload
    ```
5. 测试：  
    ![avagar](https://github.com/aNswerO/note/blob/master/13th-week/pic/nginx%E8%B4%A6%E5%8F%B7%E8%AE%A4%E8%AF%81/1.png)  
    ![avagar](https://github.com/aNswerO/note/blob/master/13th-week/pic/nginx%E8%B4%A6%E5%8F%B7%E8%AE%A4%E8%AF%81/2.png)  
