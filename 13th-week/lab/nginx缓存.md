# nginx缓存：
## 缓存相关的配置：
>调用缓存功能，需要定义在响应的配置段：http、server、location
```sh
    proxy_cache ZONE_NAME;    #指明调用的缓存；默认为off，即关闭缓存
    proxy_cache_key STRING;    #缓存中作为“键”的内容；默认值为：$scheme$proxy_host$request_uri;
    proxy_cache_valid [code ...] TIME;    #定义在http设置块中；定义对特定响应码的响应内容的缓存时长
    proxy_cache_path path [levels=levels] [use_temp_path=on|off] keys_zone=name:size [inactive=time] [max_size=size] [manager_files=number] [manager_sleep=time] [manager_threshold=time] [loader_files=number] [loader_sleep=time] [loader_threshold=time] [purger=on|off] [purger_files=number] [purger_sleep=time] [purger_threshold=time];
        #path：定义缓存的保存路径，定义好之后会自动创建
        #levels=1:2:2：定义缓存目录结构层次；1:2:2可以生成2^4x2^8x2^8=1048576个目录
        #keys_zone=proxycache:20m：指内存中缓存的大小，主要用于存放key和repodata（如使用次数）
        #inactive=120s：缓存的有效时间 
        #max_size=1g：最大磁盘占用空间，磁盘存入文件内容的缓存空间最大值
    proxy_cache_use_stale error | timeout | invalid_header | updating | http_500 | http_502 | http_503 | http_504 | http_403 | http_404 | off ;    #在代理的后端服务器出现哪种情况下，可直接使用过期的缓存响应服务器；默认是off，不启用
    proxy_cache_methods GET | HEAD | POST ...;    #对哪些客户端请求方法对应的响应进行缓存；GET和HEAD总是被缓存
    proxy_set_header FILED VALUE;    #设定发往后端主机的请求报文的请求首部的值
```

## 实验主机：
+ nginx反向代理服务器一台：192.168.1.128
+ apache后端服务器一台：192.168.1.136
+ 测试主机一台：192.168.1.159

## 实验步骤：
1. 在nginx主机上，修改nginx主配置文件，添加如下配置：  
    ![avagar](https://github.com/aNswerO/note/blob/master/13th-week/pic/%E7%BC%93%E5%AD%98/%E4%B8%BB%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6.png)  
2. 修改域www.diz.com的扩展配置文件/apps/nginx/conf/servers/diz_com.conf，添加如需下配置：  
    ![avagar](https://github.com/aNswerO/note/blob/master/13th-week/pic/%E7%BC%93%E5%AD%98/%E6%89%A9%E5%B1%95%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6.png)  
3. 使用ab命令测试：
    + 未启用缓存的测试结果：  
        ![avagar](https://github.com/aNswerO/note/blob/master/13th-week/pic/%E7%BC%93%E5%AD%98/%E6%9C%AA%E5%90%AF%E7%94%A8%E7%BC%93%E5%AD%98%E6%B5%8B%E8%AF%95.png)  
    + 重载nginx配置文件，启用缓存后的测试结果：  
        ![avagar](https://github.com/aNswerO/note/blob/master/13th-week/pic/%E7%BC%93%E5%AD%98/%E5%90%AF%E7%94%A8%E7%BC%93%E5%AD%98%E6%B5%8B%E8%AF%95.png)  
        >从测试结果看来，缓存确实起到了效果，但不够真实，在应用时未必会有这么大的响应速度的提升
