# haproxy ACL实现域名匹配调度：
## ACL相关：
+ acl的定义语法：
    ```sh
    acl <aclname> <criterion> [flags] [operator] [<value>]

    #<aclname>：acl名称
    #<criterion>：匹配条件
    #[<flags>]：条件标记位
    #<operator>：具体操作符
    #[<value>]：操作具体对象
    ```
+ 各部分解释：
    + aclname：acl名称
        + 可以使用大字母A-Z、小写字母a-z、冒号、点、中横线和下划线，且严格区分大小写

    + criterion：匹配条件
        + dst：匹配目标IP

        + dst_port：目标PORT
        + src：源IP
        + src_port：源PORT
        + hdr<STRING>：用于测试请求报文头部的指定内容：
            + hdr_dom(host) 请求的host名称，如www.qyh.com
            + hdr_beg(host) 请求的host开头，如www. img. video. download. ftp.
            + hdr_end(host) 请求的host结尾，如.com .net .cn
            + path_beg 请求的URL开头，如/static、/images、/img、/css
            + path_end请求的URL中资源的结尾，如.gif .png .css .js .jpg .jpeg
        + flags：条件标记
            + -i：不区分大小写

            + -m：使用指定的pattern匹配方法
            + -n：不做DNS解析
            + -u：禁止acl重名，否个多个重名acl匹配或关系
        + operator：操作符
            + 整数比较：eq、ge、gt、le、lt

            + 字符比较：
                + -exact match：完全匹配字符串

                + -substring match：在提取的字符串中查找，若发现其中任何一个，则匹配
                + -prefix match：在提取的字符串首部查找，若发现其中任何一个，则匹配
                + -suffix match：查看提取出来的用斜线分隔的字符串，若发现其中任何一个，则匹配
                + -domain match：查看提取出来的用点分隔的字符串，若发现其中任何一个，则匹配
            + value：具体操作对象
                + -Boolean：布尔值
                    + true

                    + false
                + -integer or integer range：整数或整数范围；如用于匹配端口范围
                + -IP address/network：用于匹配IP地址或IP范围
                + -string：
                    + exact：精确匹配
                    + substring：子串匹配
                    + suffix：后缀匹配
                    + prefix：前缀匹配
                    + subdir：路径匹配
                    + domain：域名匹配
                + -regular expression：正则表达式匹配
                + -hex block：16进制匹配
+ 多个acl作为条件时的逻辑关系：
    + 与：默认使用

    + 或：使用“or”或者“||”表示
    + 非：使用“!”表示
## 实验：
### 实验主机：
+ 负载均衡服务器：192.168.1.136

+ 后端web服务器：
    + nginx：192.168.1.159（此服务器做域名匹配测试）

    + apache：192.168.1.20（此服务器为默认调度服务器）
### 实验步骤：
1. 编辑haproxy的主配置文件，做如下配置，重载配置使之生效：
    ```
    vim /etc/haproxy/haproxy.conf
    ```  
    ![avagar](https://github.com/aNswerO/note/blob/master/14th-week/pic/ACL%E5%9F%9F%E5%90%8D%E6%8E%A7%E5%88%B6/haproxy%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6.png)  
    ```sh
    acl test_host hdr_dom(host) www.qyh.com    #根据接受到的报文，对报文头部的host信息进行匹配，若host的内容为www.qyh.com，则匹配成功；此acl的名字为test_host
    use_backend bak_1 if test_host    #若符合test_host这个acl的匹配条件，则调度到名为bak_1的backend中的主机
    default_backend default_host    #指定默认调度（即没有任何匹配时，调度到名为default_host的backend中的主机）

    backend bak_1
    backend default_host
    #指定名为bak_1和default_host的backend中的主机

    mode http    #由于需要对请求报文中的内容进行匹配，所以要使用七层负载均衡
    ```
    ```sh
    systemctl reload haproxy    #重载配置文件并开启新的进程
    ```
2. 后端服务器的配置：  
+ nginx：
    + 配置文件：  
    ![avagar](https://github.com/aNswerO/note/blob/master/14th-week/pic/ACL%E5%9F%9F%E5%90%8D%E6%8E%A7%E5%88%B6/%E5%9F%9F%E5%90%8D%E6%8E%A7%E5%88%B6%E8%B0%83%E5%BA%A6%E7%9A%84%E5%90%8E%E7%AB%AF%E6%9C%8D%E5%8A%A1%E5%99%A8%E9%85%8D%E7%BD%AE.png)  

    + 网页内容：  
    ![avagar](https://github.com/aNswerO/note/blob/master/14th-week/pic/ACL%E5%9F%9F%E5%90%8D%E6%8E%A7%E5%88%B6/%E7%BD%91%E9%A1%B5%E5%86%85%E5%AE%B9.png)  
+ apache：
    + 网页内容：  
    ![avagar](https://github.com/aNswerO/note/blob/master/14th-week/pic/ACL%E5%9F%9F%E5%90%8D%E6%8E%A7%E5%88%B6/%E9%BB%98%E8%AE%A4%E8%B0%83%E5%BA%A6%E6%9C%8D%E5%8A%A1%E5%99%A8%E7%BD%91%E9%A1%B5%E5%86%85%E5%AE%B9.png)  
3. 编辑Windows的本地解析文件并测试：
+ 添加本地解析记录：  
    ![avagar](https://github.com/aNswerO/note/blob/master/14th-week/pic/ACL%E5%9F%9F%E5%90%8D%E6%8E%A7%E5%88%B6/%E6%9C%AC%E5%9C%B0%E5%9F%9F%E5%90%8D%E8%A7%A3%E6%9E%90.png)  

+ 测试：  
    + 使用域名访问：  
    ![avagar](https://github.com/aNswerO/note/blob/master/14th-week/pic/ACL%E5%9F%9F%E5%90%8D%E6%8E%A7%E5%88%B6/%E6%B5%8B%E8%AF%95.png)  
    >被调度到nginx服务器

    + 使用IP地址访问：  
    ![avagar](https://github.com/aNswerO/note/blob/master/14th-week/pic/ACL%E5%9F%9F%E5%90%8D%E6%8E%A7%E5%88%B6/%E9%BB%98%E8%AE%A4%E8%B0%83%E5%BA%A6.png)  
    >被调度到默认服务器
