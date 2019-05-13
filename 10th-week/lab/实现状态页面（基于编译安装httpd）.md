# 实现状态页面（基于编译安装httpd）：
1. 检查配置文件中status_module模块是否启用，若没启用则将那行的注释取消：  
    ![avagar](https://github.com/aNswerO/note/blob/master/10th-week/pic/%E5%AE%9E%E7%8E%B0%E7%8A%B6%E6%80%81%E9%A1%B5%E9%9D%A2/%E6%A8%A1%E5%9D%97%E5%90%AF%E7%94%A8.png)

2. 检查模块对应的配置文件是否生效，若不生效则将那行的注释取消：  
    ![avagar](https://github.com/aNswerO/note/blob/master/10th-week/pic/%E5%AE%9E%E7%8E%B0%E7%8A%B6%E6%80%81%E9%A1%B5%E9%9D%A2/%E4%BD%BF%E5%AF%B9%E5%BA%94%E6%96%87%E4%BB%B6%E7%94%9F%E6%95%88.png)  
3. 修改/app/http24/conf/extra/httpd-info文件的内容如下：  
    ![avagar](https://github.com/aNswerO/note/blob/master/10th-week/pic/%E5%AE%9E%E7%8E%B0%E7%8A%B6%E6%80%81%E9%A1%B5%E9%9D%A2/%E4%BF%AE%E6%94%B9%E5%AF%B9%E5%BA%94%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6.png)  
4. 重启服务：
    ```
    apachectl restart
    ```
5. 测试：  
    ![avagar](https://github.com/aNswerO/note/blob/master/10th-week/pic/%E5%AE%9E%E7%8E%B0%E7%8A%B6%E6%80%81%E9%A1%B5%E9%9D%A2/%E6%B5%8B%E8%AF%95.png)
