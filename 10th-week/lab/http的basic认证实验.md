# httpd的basic认证（对用户组）：
1. 创建用户账号：
    ```shell
    htpasswd -cm /etc/httpd/conf.d/.httpuser jack
    #在上面命令执行后输入两次密码，创建jack用户，密码为md5加密，-c选项用于第一次创建用户时直接创建存放用户和密码的文件

    htpasswd -cm /etc/httpd/conf.d/.httpuser bob

    htpasswd -cm /etc/httpd/conf.d/.httpuser mike
    ```
2. 创建组文件，并增加内容：
    + 创建组文件：
        ```
        mkdir /etc/httpd/conf.d/.httgroup
        ```
    + 在组文件中添加内容：
        ```shell
        g1：jack bob
        g2：mike
        #g1和g2为自定义组名，冒号后跟组内的用户表示在此组中
        ```
3. 在配置文件中定义**安全域**（在/etc/httpd/conf.d/下新建的一个文件中配置也可以）：
    ```shell
    <directory /var/www/html/app> 
    options none
    allowoverride none
    authtype basic
    #指定认证类型
    authname "app auth"
    authuserfile /etc/httpd/conf.d/.httpuser
    #指定用户文件的位置
    authgroupfile /etc/httpd/conf.d/.httpgroup
    #指定组文件的位置
    require group g1
    #仅允许g1组中的用户在认证成功后访问
    </directory>
    ```
4. 重启httpd：
    ```
    systemctl restart httpd
    ```
5. 浏览器测试：  
    + 认证效果：  
    ![avagar](https://github.com/aNswerO/note/blob/master/10th-week/pic/basic%E8%AE%A4%E8%AF%81/%E6%B5%8B%E8%AF%95_1.png)  
    ![avagar](https://github.com/aNswerO/note/blob/master/10th-week/pic/basic%E8%AE%A4%E8%AF%81/%E6%B5%8B%E8%AF%95_2.png)  
    + 观察日志：
    ![avagar](https://github.com/aNswerO/note/blob/master/10th-week/pic/basic%E8%AE%A4%E8%AF%81/%E8%A7%82%E5%AF%9F%E6%97%A5%E5%BF%97.png) 
      >从状态码可以看出**g1**组中的jack和bob允许访问的，状态码先为401，后为200；mike在**g2**组中，不允许访问，状态码一直为401
