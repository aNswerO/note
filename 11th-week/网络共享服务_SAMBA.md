# SAMBA：
## 服务简介：
>SMB（Server Message Block）服务器消息块
+ SAMBA功能：
    + 共享文件和打印，实现了在线编辑
    + 实现登录SAMBA用户的认证
    + 可以进行NetBIOS名称解析
    + 外围设备共享

+ 计算机网络管理模式：
    + 工作组（WORKGROUP）：计算机对等关系，账号信息各自管理
    + 域（DOMAIN）：C/S架构，账号信息几种管理
## SAMBA相关包：
+ samba：提供smb服务

+ samba-client：客户端软件
+ samba-common：通用软件
+ cifs-utils：smb客户端工具
## SAMBA相关服务进程：
+ smbd：提供smb（cifs）服务
    + 端口：TCP:139,445
+ nmbd NetBIOS名称解析
    + 端口：UDP:137,138
## 主配置文件：
+ /etc/samba/smb.conf

+ 语法检查：
    ```
    testparm
    ```
## 客户端工具：
+ smbclient

+ mount.cifs
# SAMBA服务器配置：
>smb.conf继承了.ini文件的格式，用[ ]分成不同的部分；"#"和";开头的语句为注释内容，大小写不敏感
+ 全局设置：
    + [global]：服务器通用或全局设置的部分
        ```
        workgroup：指定工作组名

        server string：主机注释信息

        netbios name：指定NetBIOS名

        interfaces：指定服务器侦听接口和IP
        
        hosts allow：允许哪些主机访问；默认允许所有主机访问，也可在每个特定共享独立配置；若在[global]中设置，则会覆盖所有特定共享设置；多个主机间使用逗号、空格、tab分隔，可使用network/prefix、主机名、172.25.0.、.example.com方式表示

        hosts deny：拒绝指定主机访问

        config file=/etc/samba/conf.d/%U：用户独立的配置文件

        log file=/var/log/samba/log.%m：不同客户端采用不同日志

        log level=X：日志级别；默认为0，即不记录日志

        max log size=50：日志文件达到50k时，将轮询rorate；单位为Kb

        security的三种认证方式：
            share：匿名（CentOS-7不再支持）
            user：samba用户（采用Linux用户），samba的独立口令
            domain：使用DC（DOMAIN CONTROLLER）认证

        passdb backend=tbdsam：密码数据库格式
        ```
+ 特定共享设置：
    + [homes]：用户的家目录共享

    + [printers]：定义打印机资源和服务
    + [sharename]：自定义的共享目录配置
+ 变量：
    ```
    %m：客户端主机的NetBIOS名
    %H：当前用户家目录路径
    %g：当前用户所属组
    %L：samba服务器的NetBIOS名
    %T：当前日期和时间
    %M：客户端主机的FQDN
    %U：当前用户主机名
    %h：samba服务器的主机名
    %I：客户端主机的IP
    %S：可登录的用户名
    ```
## samba用户相关：
>samba用户须是Linux用户，建议shell类型为/sbin/nologin
+ 包：samba-common-tools

+ 工具：
    + smbpasswd
    + pdbedit
+ 添加samba用户：
    ```
    smbpasswd -a USER

    pdbedit -a -u USER
    ```
+ 修改用户密码：
    ```
    smbpasswd USER
    ```
+ 删除用户和密码：
    ```
    smbpasswd -x USER

    pdvedit -x -u USER
    ```
+ 查看samba用户列表：
    ```
    pdbedit -L -v
    ```
## 共享目录配置：
>每个共享目录都应该有独立的[ ]部分
```sh
[name]    #远程主机看到的共享目录名称
comment    #注释信息
path    #所共享的目录路径
public    #能否被guest访问的共享；默认为no
browsable    #是否允许所有用户浏览此共享；默认为yes，no为隐藏
writbale=yes    #可以被所有用户读写；默认为no
read only=no    #和writable=yes等价；若与其冲突，则位于下方的设置生效
write list    #三种形式：用户，@组名，+组名；使用逗号分隔；若writable=no，列表中用户或组可读写；不在列表中的用户或组只读
valid user    #特定用户才能访问该共享；若为空，则允许所有用户，用户名间用空格分隔
```
