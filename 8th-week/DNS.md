# DNS（Domain Name Service）：域名解析服务
+ 基于C/S架构
+ 使用端口：
    + 53/udp
    + 53/tcp
+ 本地名称解析配置文件：
    + /etc/hosts
## DNS域名：
+ 根域
+ 一级域名：com、edu、org...
+ 二级域名
+ 三级域名
>最多127级域名
## DNS的查询类型：
+ 递归查询（通常发生在客户端向本地DNS服务器发出请求后）：DNS服务器在该模式下接受到客户端的请求时，服务器必须返回客户端一个准确的查询结果；若DNS服务器本地没有存储要查询的DNS信息，那么该服务器会询问其他服务器，并将查询到的结果返回给客户端

+ 迭代查询（通常发生在本地域名服务器向**根域名服务器**发出请求后）：若DNS服务器没有可以响应的结果，该服务器会向客户端提供其他能解析查询请求的DNS服务器地址，客户端再向这个DNS服务器提交请求，循环以上步骤直到返回查询结果为止
## 解析类型：
+ 正向解析：FQDN --> IP
+ 反向解析：IP --> FQDN
>正、反向解析时两个不同的名称空间，是两棵不同的解析树
## DNS的服务器类型：
+ 主DNS服务器：

    + 管理和维护所负责解析的域内解析库的服务器
+ 从DNS服务器：
    + 从主DNS服务器或从服务器复制解析库副本
+ 缓存（转发）DNS服务器
>通知机制：主服务器解析库发生变化时，会主动通知从服务器
## DNS解析：
+ 一次完整的查询请求经过的流程：
    1. 客户端检查本地名称解析hosts文件；找到要查询的记录则返回给客户端

    2. 没有找到需要的记录时，向**本地域名服务器**发出请求，此过程为**递归查询**；找到要查询的记录则返回给客户端
    3. 还没有找到记录时会由**本地域名服务器**向一个**根域名服务器**采用**迭代查询**
    4. **根域名服务器**向**本地域名服务器**返回下一次应查询的域名服务器（**顶级域名服务器**）的IP地址
    5. **顶级域名服务器**返回下一次应查询的DNS服务器（**权威域名服务器**）的IP地址
    6. 本地域名服务器查询**权威域名服务器**、
    7. **权威域名服务器**返回最终的查询结果（目标IP地址），并将其返回给**本地域名服务器**
    8. **本地域名服务器**将接收到的查询结果返回给客户端
+ 解析答案：
    + 肯定答案：查询的域名存在，域名与IP的对应关系会被缓存下来

    + 否定答案：查询的域名不存在，因此不存在与其对应的IP地址，此记录也会被缓存下来
    + 权威答案：所查询的域名结果是由负责解析这个域的域名服务器（**权威域名服务器**）返回的结果
    + 非权威答案：在缓存中查询到的结果
## RR（Resource Record）：资源记录
+ 资源记录定义的格式：
```shell
    name [TTL] IN RR_TYPE VALUE
```
+ 注意：
1. TTL可从全局继承
2. @可用于引用当前区域的名字
3. 同一个名字可以通过多条记录定义多个不同的值；此时DNS服务器会以轮询方式响应
4. 同一个值也可能有多个不同的定义名字；通过这种方式可以通过多个不同的域名找到同一台主机

+ 记录类型：
    + SOA：
        + name：当前区域的名字
        + value：有多个部分组成
            1. 当前区域的主DNS服务器的FQDN，也可以使用当前区域的名字（@）
            2. 当前区域管理员的邮箱地址；但地址中出现的"@"，一律用"."替代
            3. 主从服务区域传输相关定义以及否定答案的统一TTL
                + 序列号：每次人为使此文件进行“**有效性**”修改时，手动为序列号加1，以表示该文件发生过改动
                + 刷新时间：从服务器多久从主服务器同步一次
                + 重试时间：与主服务器同步失败时，重试间隔时间
                + 过期时间：与主服务器无法同步后，过多久使从服务器的数据失效，并停止提供服务
                + 否定答案的TTL值：否定答案的缓存时长

    + A：正向解析，将FQDN（全称域名）解析成IPv4地址
        + name：某主机的FQDN
        + value：主机名对应的IPv4地址
        >避免用户大意写错域名时给出错误答案，可通过**泛域名解析**来解析某特定地址  
        如：*.baidu.com IN  A   1.1.1.6
    + AAAA：正向解析，将FQDN解析成IPv6地址
    + PTR：PoinTeR，用于反向解析
        + name：有特定格式的IP；将IP地址反写，如123.234.345.456写成456.345.234.123；再在后面加上后缀，如456.345.234.123.ip-addr.arpa
        >网络地址及其后缀可以省略，但主机地址仍然需要反写
    + NS：Name Server，用于标明当前**区域**的DNS服务器
        + name：当前区域的名字
        + value：当前区域的某DNS服务器的名字
        >1.一个区域可以有多个NS记录  
        2.相邻的两个资源记录的name相同时，后续的可省略  
        3.对NS记录而言，任何一个NS记录后的服务器名字，都要对应着一个A记录
    + CNAME：Canonical Name，别名记录
        + name：别名的FQDN
        + value：真正的FQND
    + MX：Mail eXchange，邮件交换器
        + name：当前区域的名字
        + value：当前区域的某邮件服务器（smtp服务器）的主机名
        + 一个区域内，MX记录可有多个；但每个记录的value之前必须要有一个此服务器的优先级（0 ~ 99，数值越小优先级越高）
        >与NS记录一样：对MX记录而言，任何一个MX记录后的服务器名字，都要对应着一个A记录
    + TXT：对域名进行标识和说明的一种方式，一般用验证记录时会用此项；如SPF（反垃圾邮件）、https验证等
# BIND：
## 安装bind：
```
    yum install -y bind
```
## 查看BIND相关程序包：
```shell
    yum list all bind*

    #bind：服务器
    #bind-libs：相关库
    #bind-utils：客户端
    #bind-chroot：/var/named/chroot/
```
## BIND服务器相关：
+ 服务脚本：/etc/rc.d/init.d/named
+ 服务名称：/usr/lib/systemd/system/named.service
+ 主配置文件：/etc/named.conf、/etc/named.rfc1912.zone、/etc/rndc.key
    + 全局配置：
    >1.任何服务程序若希望能被其他主机通过网络访问，那么它至少应该监听在一个能与外部主机通信的IP地址上  
    2.关闭dnssec。dnssec全称为Domain Name System Security Extensions（DNS安全扩展），它可提供一种验证应答信息真实性和完整性的机制，但标记和校验DNS信息会影响性能，所以在实验中会选择关闭dnssec
  
    ![avagar](https://github.com/aNswerO/note/blob/master/8th-week/pic/DNS%E4%B8%BB%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B61.png)  
    ![avagar](https://github.com/aNswerO/note/blob/master/8th-week/pic/DNS%E4%B8%BB%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B64.png)
    + 日志子系统配置：  
    ![avagar](https://github.com/aNswerO/note/blob/master/8th-week/pic/DNS%E4%B8%BB%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B62.png)
    + 区域定义(此处为根域)：  
    ![avagar](https://github.com/aNswerO/note/blob/master/8th-week/pic/DNS%E4%B8%BB%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B63.png)
+ 解析库文件：/var/named/ZONE_NAME.zone
>1.一台物理服务器可同时为多个区域提供解析  
2.必须要有根区域文件：named.ca  
3.应有两个（若包括IPv6地址，需要更多）实现localhost和本地回环地址的解析库
# 主DNS服务器：
+ 搭建主DNS服务器：

    1. 在主配置文件中定义区域
    2. 定义区域解析库文件
+ 主配置文件语法检查：
```
    named-checkconf
```
+ 解析库文件语法检查：
```
    named-checkzone "ZONE_NAME" /PATH/TO/ZONE_NAME.zone
```
+ 使配置生效的两种方法：
```
    rndc reload 
    service named reload
```
## 反向区域：
+ 区域名称：IP地址反写.in-addr.arpa

+ 定义区域：
```shell
    zone "ZONE_NAME" IN {
        type {master|slave|forward};
        file "IP地址.zone";
    };
```
+ 定义解析库文件：
    + 不需要MX记录，以PTR记录为主

# 从服务器：
1. 应该为一台独立的域名服务器

2. 此从服务器的主服务器的区域解析库文件中必须要有一条NS记录指向此从服务器
3. 从服务器中只需定义区域，无需提供解析库文件；
4. 主服务器需要允许从服务器进行区域传送
5. 主从服务器时间应该同步；可通过ntp进行
6. 主、从服务器的bind程序版本应保持一致；否则，主服务器的bind版本必须低于从服务器的bind版本
## 定义从区域：
```shell
    zone "ZONE_NAME" IN {
        type slave;
        masters {MASTER_IP;};
        file "slave/ZONE_NAME.zone";
    };
```
# 子域：
+ 子域授权：实现分布式；每个子域的域名服务器，都要通过其父域的域名服务器在解析库进行**授权**

## 定义子域：
+ 在父域的解析库文件添加一条NS记录和一条与之对应的A记录以完成**授权**
# 转发服务器：
>被转发的服务器需要能够为请求者做递归查询，否则转发请求不予执行
+ 全局转发：对非本机所负责解析区域的请求，全转发到指定服务器；应配置在主配置文件中
```
    Options {
        forward first|only;
        forward {ip;};
    };
```
+ 特定区域转发：仅转发特定区域的请求，优先级比全局转发优先级高
```shell
    zone "ZONE_NAME" IN {
        type forward;
        forward first|only;   #first：先向转发到的指定服务器发出请求，若此请求无法得到解析结果，会用指定服务器保存的根域名服务器进行解析      only：若无法通过转发到的服务器解析域名，便无法解析域名
        forwarders {ip;};
    };
```
# BIND中的ACL：
+ acl：把一个或多个地址并为一个集合，使用时使用一个统一的名称调用
>只能先定义后使用，所以一般要定义在配置文件中，且位于options段之前
+ 格式：
```
    acl acl_name {
        IP;
        net/prelan;
        ...;
    }
```
+ BIND中内置的acl：
    + none：没有任何主机
    + any：任何主机
    + localhost：本机
    + localnet：本机的网络地址
+ 访问控制的指令：
    + allow-query {}：允许哪些主机查询
    + allow-transfer {}：允许哪些主机进行区域传送
    + allow-recursion {}：允许哪些主机递归查询
    + allow-update {}：允许哪些主机更新区域数据库的内容；大多数情况为none
# 智能DNS：
## view（视图）：
+ 一个bind服务器可定义多个view，每个view中可定义一个或多个zone
+ 每个view用来匹配一组客户端
+ 多个view内可能需要对同一个区域进行解析，但使用不同的区域解析库文件
>1.一旦启用了view，所有的zone都必须定义在view  
2.仅在云溪递归请求的客户端所在view中定义根区域  
3.客户端请求到达时，自上而下检查每个view所服务的客户端列表
# rndc命令：
>使用rndc可以在不停止DNS服务的情况下使修改后的配置文件生效
+ command：
    + reload：重载主配置文件和区域解析数据库文件

    + reload zonename：重载区域解析库文件
    + retransfer zonename：手动发起区域传送，无论序列号是否增加
    + notify zonename：重新对区域传送发通知
    + reconfig：重载主配置文件
    + querylog：开启或关闭查询日志文件（/var/log/message）
    + trace：递增debug级别
    + trace LEVEL：指定使用的级别
    + notrace：将调试级别设置为0
    + flush：清空DNS服务器的所有缓存记录

# 测试命令：
## dig命令：
>dig只用于测试DNS系统，不会查询hosts文件进行解析
+ 使用方法：
```
    dig [-t type] name [@SERVER] [QUERY_OPTIONS]
```
+ 选项：
    + +trace：跟踪解析过程
    + +recurse：进行递归解析
    + -x：反向解析
