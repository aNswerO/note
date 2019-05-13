# 基于编译安装httpd的实用户家目录共享,并实现basic认证：
1. 在目录/app/httpd24/下创建一个名为conf.d的目录：
    ```
    mkdir /app/httpd24/conf.d
    ```
    
2. 在主配置文件中取消Include conf/extra/httpd-userdir.conf和LoadModule userdir_module modules/mod_userdir.so这两行的注释，启用这个模块，并修改Include conf/extra/httpd-userdir.conf文件的内容如下图：  
    ![avagar](https://github.com/aNswerO/note/blob/master/10th-week/pic/%E5%AE%9E%E7%8E%B0%E7%94%A8%E6%88%B7%E5%AE%B6%E7%9B%AE%E5%BD%95%E5%85%B1%E4%BA%AB/%E5%BC%80%E5%90%AF%E6%8C%87%E5%AE%9A%E6%A8%A1%E5%9D%97.png)  
    + 在配置文件中做修改以启用模块，并使对应模块的配置文件生效：  
    ![avagar](https://github.com/aNswerO/note/blob/master/10th-week/pic/%E5%AE%9E%E7%8E%B0%E7%94%A8%E6%88%B7%E5%AE%B6%E7%9B%AE%E5%BD%95%E5%85%B1%E4%BA%AB/%E5%90%AF%E7%94%A8%E6%A8%A1%E5%9D%97.png)  
    ![avagar](https://github.com/aNswerO/note/blob/master/10th-week/pic/%E5%AE%9E%E7%8E%B0%E7%94%A8%E6%88%B7%E5%AE%B6%E7%9B%AE%E5%BD%95%E5%85%B1%E4%BA%AB/%E6%89%BE%E5%88%B0%E5%AF%B9%E5%BA%94%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6.png)
3. 添加用户：
    ```
    htpasswd -cw /app/httpd24/conf.d/.httpuser jack

    htpasswd -w /app/httpd24/conf.d/.httpuser bob
    ```
4. 在用户家目录下创建一个用于共享的目录public，并新建主页文件index.html：
    ```sh
    mkdir ~qyh/public

    setfacl -m user:apache:x ~qyh    #为用户家目录添加acl，使apache用户对此目录具有执行权限

    vim ~qyh/public/index.html
    <h1>test</h1>
    ```
5. 在/home/qyh/public/下创建一个名为.htacess的文件：
    ```sh
    authtype basic
    authname "admin page"
    authuserfile "/app/httpd24/conf.d/.httpuser"
    require user jack    #允许jack在认证成功后访问目录
    ```
6. 测试：  
    ![avagar](https://github.com/aNswerO/note/blob/master/10th-week/pic/%E5%AE%9E%E7%8E%B0%E7%94%A8%E6%88%B7%E5%AE%B6%E7%9B%AE%E5%BD%95%E5%85%B1%E4%BA%AB/%E6%B5%8B%E8%AF%95.png)  
    >用户jack认证成功并访问到共享目录下的文件
