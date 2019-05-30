# nginx自定义错误页面：
1. 在配置文件中添加配置：  
    ![avagar](https://github.com/aNswerO/note/blob/master/13th-week/pic/%E8%87%AA%E5%AE%9A%E4%B9%89%E9%94%99%E8%AF%AF%E9%A1%B5%E9%9D%A2/%E9%85%8D%E7%BD%AE.png)
2. 测试：  
    ![avagar](https://github.com/aNswerO/note/blob/master/13th-week/pic/%E8%87%AA%E5%AE%9A%E4%B9%89%E9%94%99%E8%AF%AF%E9%A1%B5%E9%9D%A2/%E6%B5%8B%E8%AF%95.png)  

# nginx自定义访问日志：
1. 在配置文件中添加配置：  
    ![avagar](https://github.com/aNswerO/note/blob/master/13th-week/pic/%E8%87%AA%E5%AE%9A%E4%B9%89%E6%97%A5%E5%BF%97/%E9%85%8D%E7%BD%AE.png)  
2. 重启nginx使配置文件中的日志文件生成：
    ```
    systemctl restart nginx
    ```
3. 访问网站，查看日志文件中的内容：  
    ![avagar](https://github.com/aNswerO/note/blob/master/13th-week/pic/%E8%87%AA%E5%AE%9A%E4%B9%89%E6%97%A5%E5%BF%97/%E7%94%9F%E6%88%90%E4%BA%86%E6%97%A5%E5%BF%97%E6%96%87%E4%BB%B6.png)  

# nginx自定义JSON格式日志：
1. 在主配置文件中添加配置：  
    ![avagar](https://github.com/aNswerO/note/blob/master/13th-week/pic/%E8%87%AA%E5%AE%9A%E4%B9%89%E6%97%A5%E5%BF%97/json%E6%A0%BC%E5%BC%8F%E6%97%A5%E5%BF%97%E9%85%8D%E7%BD%AE.png)  
2. 重载nginx配置文件并测试：  
    ![avagar](https://github.com/aNswerO/note/blob/master/13th-week/pic/%E8%87%AA%E5%AE%9A%E4%B9%89%E6%97%A5%E5%BF%97/JSON%E6%A0%BC%E5%BC%8F%E6%97%A5%E5%BF%97%E6%B5%8B%E8%AF%95.png)  
