# zabbix：
监控软件存在的意义是为保证业务稳定运行，它需要能及时使运维人员发现异常
## zabbix的核心任务：
+ 采集：
    + agentless（无需代理）：SNMP、Telnet、ssh、JMX、IPMI

    + agent（需代理）：zabbix agent
+ 存储
+ 展示
+ 告警
## zabbix的组件：
+ zabbix server：负责接收zabbix发送的报告信息，并负责组织配置信息、统计信息、操作数据

+ zabbix agent：部署在被监控的主机，负责将被监控主机的数据发送给zabbix server
+ zabbix database：用于存储所有zabbix的配置信息和监控数据的数据库
+ zabbix web：zabbix的web页面，管理员可以通过web页面对zabbix进行配置管理，并查看监控信息
+ zabbix proxy：用于分布式监控环境中，它们代表了zabbix server，由它们对局部区域进行信息收集，再统一发往zabbix server
## zabbix的工作模式：
>这里的主动/被动模式都是对于zabbix agent来说的，这两种模式可以共存，且不冲突
+ 主动模式：agent将数据主动发送给server

+ 被动模式：agent等待server来拉取数据
## 二进制包安装zabbix（ubuntu 18.04）：
### 规划：
|角色|主机名|IP|
|--|--|--|
|zabbix server|server|192.168.6.150|
|zabbix agent|agent|192.168.6.151|
### 步骤：
1. 更换软件源为国内源：
    ```
    [root@server ~]#vim /etc/apt/sources.list

    deb http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse
    deb-src http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse

    deb http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse
    deb-src http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse

    deb http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse
    deb-src http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse

    deb http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse
    deb-src http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse

    deb http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse
    deb-src http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse
    ```
2. 添加zabbix软件仓库：
    ```
    [root@server ~]#wget https://repo.zabbix.com/zabbix/4.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_4.0-2+bionic_all.deb
    ```
    ```
    [root@server ~]#dpkg -i zabbix-release_4.0-2+bionic_all.deb
    ```
    ```
    [root@server ~]#apt update
    ```
3. 安装软件：
    + 安装zabbix server并使用数据库（对于server和proxy，数据库是必需的，agent则不需要）：
        ```
        [root@server ~]#apt install zabbix-server-mysql
        ```
    + 安装zabbix前端：
        ```
        [root@server ~]#apt install zabbix-frontend-php
        ```
4. 创建数据库并授权：
    + 创建数据库：
        >若要将server和proxy安装在同一主机，那么必需创建不同名字的数据库给它们使用，此处只安装了server，所以只创建一个名为zabbix的数据库 
        ```
        MariaDB [(none)]> create database zabbix character set utf8 collate utf8_bin;
        ```
        >若创建数据库时未指定上述参数，在初始化数据库时则会出现错误  
    + 授权：
        ```
        MariaDB [(none)]> grant all on zabbix.* to zabbix@'192.168.6.%' identified by '123456';  
        ```
        >由于授权的是192.168.6.0/24网段中的主机，但配置文件（/etc/mysql/mariadb.conf.d/50-server.cnf）中默认的监听地址为127.0.0.1，所以需要将配置文件中的bind-address=127.0.0.1改为bind-address=192.168.6.150，之后重启mariadb
5. 使用mysql导入zabbix server的初始化数据库schema和数据：
    >此步骤需要输入zabbix的密码
    ```
    [root@server ~]#zcat /usr/share/doc/zabbix-server-mysql/create.sql.gz | mysql -uzabbix -p zabbix -h 192.168.6.150
    ```
    + 验证表是否写入：
        ```
        MariaDB [(none)]> show tables from zabbix;
        ```
6. 为server配置数据库：
    + 编辑配置文件以使用以创建的数据库
    ```
    [root@server ~]#vim /etc/zabbix/zabbix_server.conf 
    ```
    >重要配置：  
    DBHost=192.168.6.150  
    DBName=zabbix  
    DBUser=zabbix  
    DBPassword=123456
7. 启动zabbix server进程：
    ```
    [root@server ~]#systemctl start zabbix-server
    ```
8. 配置前端：
    ```
    [root@server ~]#vim /etc/apache2/conf-enabled/zabbix.conf 
    ```
    >使用php -v命令查看php的版本，并将对应配置段的时区那行取消注释，并改为php_value date.timezone Asia/Shanghai
9. 192.168.6.151安装zabbix agent：
    + 安装：
        ```
        [root@agent ~]#apt install zabbix-agent
        ```
    + 启动：
        ```
        [root@agent ~]#systemctl start zabbix-agent
        ```
    + 修改配置文件：
        ```
        [root@agent ~]#vim /etc/zabbix/zabbix_agentd.conf
        ```
        + Passive checks related（被动模式配置段）：
            ```conf
            Server=192.168.6.150
            #工作于被动模式时，指定哪台服务器可以从当前服务器拉取数据，可以指定多个IP，使用逗号分隔
            ```
        + Active checks related（主动模式配置段）：
            ```conf
            ServerActive=192.168.6.150
            #工作于主动模式时，指定向哪台server推送数据，可以指定多个IP，使用逗号分隔
            Hostname=agent
            #用于指定当前主机的主机名，server通过此参数对应的主机名识别当前主机
            RefreshActiveChecks=60
            #用于指明agent多久主动将数据推送到server
            ```
        + 重启agent：
            ```
            [root@agent ~]#systemctl restart zabbix-agent
            ```
        + 查看agent日志： 
            >如果配置文件中的Hostname与zabbix web中的主机名不一致，日志中会报错
            ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/zabbix%E7%AE%80%E5%8D%95%E9%83%A8%E7%BD%B2/agentagent%E6%97%A5%E5%BF%97.png)  
10. 在server测试采集agent的数据：
    ```
    [root@server ~]#zabbix_get -s 192.168.6.151 -p 10050 -k "system.cpu.load[all,avg1]"
    ```  
    ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/zabbix%E7%AE%80%E5%8D%95%E9%83%A8%E7%BD%B2/%E6%B5%8B%E8%AF%95%E9%87%87%E9%9B%86%E6%95%B0%E6%8D%AE.png) 
11. 在server端也安装agent，以使server可以监控自己：
    ```
    [root@server ~]#vim /etc/zabbix/zabbix_agentd.conf
    ```
    + Passive checks related（被动模式配置段）：
        ```conf
        Server=127.0.0.1
        #工作于被动模式时，指定哪台服务器可以从当前服务器拉取数据，可以指定多个IP，使用逗号分隔
        ```
    + Active checks related（主动模式配置段）：
        ```conf
        ServerActive=127.0.0.1
        #工作于主动模式时，指定向哪台server推送数据，可以指定多个IP，使用逗号分隔
        Hostname=erver
        #用于指定当前主机的主机名，server通过此参数对应的主机名识别当前主机
        RefreshActiveChecks=60
        #用于指明agent多久主动将数据推送到server
        ```
    + 重启agent：
        ```
        [root@server ~]#systemctl restart zabbix-agent
        ```  
12. 访问页面：
    + 浏览器输入192.168.6.150/zabbix：  
        ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/zabbix%E7%AE%80%E5%8D%95%E9%83%A8%E7%BD%B2/%E9%A1%B5%E9%9D%A21.png)  
        ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/zabbix%E7%AE%80%E5%8D%95%E9%83%A8%E7%BD%B2/%E9%A1%B5%E9%9D%A22.png)  
        >确保全为ok  
        ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/zabbix%E7%AE%80%E5%8D%95%E9%83%A8%E7%BD%B2/%E9%A1%B5%E9%9D%A23.png)  
        >database port为0表示使用默认端口3306
        ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/zabbix%E7%AE%80%E5%8D%95%E9%83%A8%E7%BD%B2/%E9%A1%B5%E9%9D%A24.png)  
        ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/zabbix%E7%AE%80%E5%8D%95%E9%83%A8%E7%BD%B2/%E9%A1%B5%E9%9D%A25.png)  
        ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/zabbix%E7%AE%80%E5%8D%95%E9%83%A8%E7%BD%B2/%E9%A1%B5%E9%9D%A26.png)  
    + 登录：  
        >用户名为Admin，密码为zabbix  
        ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/zabbix%E7%AE%80%E5%8D%95%E9%83%A8%E7%BD%B2/%E7%99%BB%E5%BD%95.png)  
13. 将语言改为中文：
    + 安装中文语言包：
        ```
        [root@server fonts]#apt install language-pack-zh-hans
        ```
    + 重启apache2：
        ```
        [root@server ~]#systemctl restart apache2
        ```  
    + 刷新页面：  
        ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/zabbix%E7%AE%80%E5%8D%95%E9%83%A8%E7%BD%B2/%E6%94%B9%E4%B8%BA%E4%B8%AD%E6%96%87.png)  
14. 解决中文部分乱码的问题：
    + 从windows系统中将选定的字体（位于C:\Windows\Fonts）发送到server的/usr/share/zabbix/assets/fonts/目录下  
        ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/zabbix%E7%AE%80%E5%8D%95%E9%83%A8%E7%BD%B2/%E5%AD%97%E4%BD%93%E6%96%87%E4%BB%B6.png)  
        >注意要将文件后缀名改为小写

    + 修改配置文件[root@server fonts]#vim /usr/share/zabbix/include/defines.inc.php中的"graphfont"改为"STXINWEI"  
   
    + 查看页面，乱码问题解决，以下是server端监控自己采集到的数据：  
        ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/zabbix%E7%AE%80%E5%8D%95%E9%83%A8%E7%BD%B2/%E4%B8%8D%E5%86%8D%E4%B9%B1%E7%A0%81.png)  
15. 通过web界面添加主机：  
    + 添加主机：  
    ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/zabbix%E7%AE%80%E5%8D%95%E9%83%A8%E7%BD%B2/%E6%B7%BB%E5%8A%A0%E4%B8%BB%E6%9C%BA.png)  
    + 为主机添加模板：  
    ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/zabbix%E7%AE%80%E5%8D%95%E9%83%A8%E7%BD%B2/%E4%B8%BA%E4%B8%BB%E6%9C%BA%E6%B7%BB%E5%8A%A0%E6%A8%A1%E6%9D%BF.png)  
    ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/zabbix%E7%AE%80%E5%8D%95%E9%83%A8%E7%BD%B2/%E5%BA%94%E7%94%A8.png)  
    ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/zabbix%E7%AE%80%E5%8D%95%E9%83%A8%E7%BD%B2/%E5%BA%94%E7%94%A8%E5%AE%8C%E6%88%90.png)  
16. 查看采集到的agent的数据：  
    ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/zabbix%E7%AE%80%E5%8D%95%E9%83%A8%E7%BD%B2/%E6%9F%A5%E7%9C%8B%E7%9B%91%E6%8E%A7%E6%95%B0%E6%8D%AE.png)  
