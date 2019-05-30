# nginx启用压缩：
>nginx支持对指定类型的文件进行压缩然后再传输给客户端，而且压缩还可以设置压缩比，压缩后的文件与源文件相比会明显变小；这样有助于降低出口带宽的利用率，降低企业的IT支出，不过会占用相应的CPU资源  
nginx对文件的压缩功能是依赖于ngx_http_gzip_module
1. 压缩前资源大小：  
    ![avagar](https://github.com/aNswerO/note/blob/master/13th-week/pic/%E5%8E%8B%E7%BC%A9/%E5%8E%8B%E7%BC%A9%E5%89%8D.png)  
2. 修改主配置文件开启压缩：  
    ![avagar](https://github.com/aNswerO/note/blob/master/13th-week/pic/%E5%8E%8B%E7%BC%A9/%E9%85%8D%E7%BD%AE.png)  
3. 压缩后资源大小：  
    ![avagar](https://github.com/aNswerO/note/blob/master/13th-week/pic/%E5%8E%8B%E7%BC%A9/%E5%8E%8B%E7%BC%A9%E5%90%8E.png)  
# 有关压缩的配置参数：
+ gzip on：启用压缩；off为不启用

+ gzip_comp_level：指定压缩比；默认为1，压缩比由低到高，级别为1~9
+ gzip_disable "MSIE [1-6]\."：禁用IE6 gzip功能
+ gzip_min_length 1k：gzip压缩的最小文件，小于此值的文件不会被压缩
+ gzip_http_version：启用压缩功能时，协议的最小版本
+ gzip_type mime-type：指明对哪些类型的资源执行压缩操作；默认为gzip_types text/html；不用显式指定，否则会出错
+ gzip_vary on：若启用压缩，是否在响应报文首部插入“Vary: Accept-Encoding”
