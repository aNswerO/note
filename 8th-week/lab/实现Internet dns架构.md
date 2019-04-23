# 实验要求：
+ 七台虚拟机，分别用作：客户端、本地域名服务器、根域名服务器、顶级域名服务器、权威域名服务器、权威域名服务器的从服务器、web服务器
+ 客户端、本地域名服务器与web服务器无需安装bind，其他主机需要安装
+ 关闭防火墙、SELinux
+ 每个DNS服务器的主配置文件做如下改动，以对外开启DNS服务;并将每个DNS服务器的named服务启动
+ web服务器开启httpd服务
# 实验拓扑：  
![avagar](https://github.com/aNswerO/note/blob/master/8th-week/pic/%E6%8B%93%E6%89%91.png)
# 实验步骤：
1. 本地域名服务器：
    + 修改/var/named/named.ca文件，删除自带的根域名服务器，只留下自己搭建的根域名服务器的NS和A记录，如下图所示：  
    ![avagar](https://github.com/aNswerO/note/blob/master/8th-week/pic/dns_lab_local.png)
2. 根域名服务器：
    + 修改/etc/named.conf文件，将自带的“.”的zone字段内的内容修改成如下图所示：  
    ![avagar](https://github.com/aNswerO/note/blob/master/8th-week/pic/dns_lab_root.png)
    + 执行rndc reload

3. 顶级域名服务器：
    + 编辑/etc/named.rfc1912.zones文件，添加一个zone段，内容如下图所示：  
    ![avagar](https://github.com/aNswerO/note/blob/master/8th-week/pic/dns_lab_%E9%A1%B6%E7%BA%A7%E5%9F%9F%E5%90%8D%E6%9C%8D%E5%8A%A1%E5%99%A81.png)
    + 以/var/named/named.localhost文件为模板，创建/var/named/com.zone文件，内容如下图所示：
    ```shell
        cp -p /var/named/named.localhost /var/named/com.zone
        #使用-p选项，保留权限信息
    ```  
    ![avagar](https://github.com/aNswerO/note/blob/master/8th-week/pic/dns_lab_%E9%A1%B6%E7%BA%A7%E5%9F%9F%E5%90%8D%E6%9C%8D%E5%8A%A1%E5%99%A82.png)
    + 执行rndc reload
4. 权威域名服务器：
    + 主服务器：
        + 编辑/etc/named.conf文件，在options段中加入如图所示内容，允许与从服务器进行区域传送：  
        ![avagar](https://github.com/aNswerO/note/blob/master/8th-week/pic/dns_lab_%E4%B8%BB3.png)
        + 编辑/etc/named.rfc1912.zones文件，添加一个zone段，内容如下图所示：  
        ![avagar](https://github.com/aNswerO/note/blob/master/8th-week/pic/dns_lab_%E4%B8%BB1.png)
        + 同顶级域名服务器，以/var/named/named.localhost文件为模板，创建/var/named/qyh.com.zone文件，内容如下图所示：  
        ![avagar](https://github.com/aNswerO/note/blob/master/8th-week/pic/dns_lab_%E4%B8%BB2.png)
        + 执行rndc reload
    + 从服务器：
        + 编辑/etc/named.rfc1912.zones文件，添加一个zone段，内容如下图所示：  
        ![avagar](https://github.com/aNswerO/note/blob/master/8th-week/pic/dns_lab_%E4%BB%8E1.png)
        + 执行rndc reload
5. 测试：  
![avagar](https://github.com/aNswerO/note/blob/master/8th-week/pic/%E6%B5%8B%E8%AF%951.png)
