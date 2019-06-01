# nginx防盗链：
## 盗链：
>若有人只链接了某个网站（非自己的）的图片或某个单独的资源，而不是打开了整个页面，这就被称为“盗链”

## 防盗链：
>防盗链基于客户端携带的referer实现；referer是记录打开一个页面之前，记录是从哪个页面跳转过来的标记信息
+ 正常的referer信息有以下几种：
    + none：请求报文首部没有referer首部，比如用户直接在浏览器输入域名访问web网站，就没有referer信息

    + blocked：请求报文有referer首部，但无有效值，比如为空
    + server_names：referer首部中包含本主机名（即nginx监听的server name）
    + arbitrary_string：自定义指定字符串，但可以使用*作通配符
    + regular expression：被指定的正则表达式模式匹配到的字符串，要使用~开头
1. 编辑配置文件，添加如下配置：  
    ![avagar](https://github.com/aNswerO/note/blob/master/13th-week/pic/%E9%98%B2%E7%9B%97%E9%93%BE/%E9%85%8D%E7%BD%AE.png)  
2. 准备盗链页面：  
    ![avagar](https://github.com/aNswerO/note/blob/master/13th-week/pic/%E9%98%B2%E7%9B%97%E9%93%BE/%E7%9B%97%E9%93%BE%E4%BB%A3%E7%A0%81.png)  
3. 测试：  
    ![avagar](https://github.com/aNswerO/note/blob/master/13th-week/pic/%E9%98%B2%E7%9B%97%E9%93%BE/%E6%B5%8B%E8%AF%95.png)
