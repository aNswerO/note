# 存储基础知识：存储网络
+ 直接存储（DAS——Direct Attached Storage）：
    >存储设备与主机紧密相连
    + 管理成本较低，实施简单

    + 存储时直接依附在服务器上，因此存储共享收到限制
    + CPU必须同时完成磁盘存取和应用运行的双重任务，所以不利于CPU的指令周期的优化，增加系统负担

+ 网络连接存储（NAS——Network Attached Storage）：
    >通过局域网在多个文件服务器之间实现了互联，基于文件的协议（FTP、NFS、SMB/CIFS等）实现文件共享
    + 集中管理数据，从而释放带宽、提高性能

    + 可提供跨平台文件共享功能
    + 可靠性较差，使适用于局域网或较小的网络
+ 存储区域网络（SAN——Storage Area Networks）：
    >利用高速的光纤网络连接服务器与存储设备，基于SCSI，IP，ATM等多种高级协议，实现存储共享
    + 服务器跟存储装置两者各司其职

    + 利用光纤信道传输数据，以达到一个服务器与存储装置之间多对多的高效能、高稳定度的存储环境
    + 实施复杂，管理成本高  
+ 三者的对比：  

||DAS|NAS|SAN|
|--|--|--|--|
|传输类型|SCSI、FC|IP|IP、FC、SAS|
|数据类型|数据块|文件|数据块|
|典型应用|任何|文件服务器|数据块应用|
|优点|磁盘与服务器分离，便于统一管理|不占用应用服务器资源、广泛支持操作系统、扩展较容易、即插即用、安装简单方便|高扩展性、高可用性、数据集中、易管理|
|缺点|连接距离短、数据分散、共享困难、存储空间利用率不高、扩展性有限|不适合存储量大的块级应用、数据备份和恢复占用网络带宽|相比NAS成本较高，安装和升级比NAS复杂|
# 文件传输协议——FTP：
>File Transfer Protocol 早期的三个应用级协议之一
+ 基于C/S架构

+ 双通道协议：数据和命令连接
+ 数据传输格式：二进制（默认）和文本
+ 两个通道：
    + 命令通道：使用21/tcp端口

    + 传输通道：
        + 当应用模式为**主动模式**时：使用20/tcp端口
        + 当应用模式为**被动模式**时：使用端口随机，由客户端和服务器通过**命令通道**协商得到
+ 两种模式（服务器角度）：
    + 主动（PORT style）：服务器主动连接
    + 被动（passive）：客户端主动连接
        + 服务器被动模式数据端口示例：
        ```shell
        227 Entering Passive Mode (172,16,0,1,224,59)
        #服务器随机端口通过224和59这两个数字经过计算得到，计算方法为224*256+59，得出随机端口的端口号为：57403
        ```
+ 状态码：
    ```shell
    1XX：肯定的初步答复；这些状态码表示一项操作已经成功开始，但客户端希望在继续操作新命令前得到另一个答复

    2XX：肯定的完成答复；这些状态码表示一项操作已经成功完成，客户端可以执行新命令

    3XX：肯定的中间答复；命令已成功，但服务器需要更多来自客户端的信息以完成对请求的处理

    4XX：瞬态否定的完成答复；命令不成功，但错误时暂时的，若客户端重试命令，可能会成功

    5XX：语法错误；命令无法识别
    ```
+ 用户认证：
    + 匿名用户：anonymous，对应Linux中的ftp用户

    + 系统用户：Linux用户，用户名存于/etc/passwd、密码存于/etc/shadow
    + 虚拟用户：ftp服务专用用户，有独立的用户/密码文件
# vsftp服务：
+ 由vsftpd包提供
    + 安装：
        ```
        yum install -y vsftpd
        ```

+ 服务脚本：
    + CentOS-7：/usr/lib/systemd/system/vsftpd.service
    + CentOS—6：/etc/rc.d/init.d/vsftpd
+ 配置文件：/etc/vsftpd/vsftpd.conf
    + 格式：option=value（“=”前后不能有空格）
+ 用户认证配置文件：/etc/pam.d/vsftpd
+ 匿名用户：映射为系统用户ftp
    + 共享文件位置：/var/ftp
+ 系统用户共享文件位置：/用户家目录
+ 虚拟用户共享文件位置：为其映射的系统用户的家目录
## vsftpd服务器配置：
+ 命令端口：
    ```
    listen_port=21
    ```
+ 主动模式端口：
    ```sh
    connect_from_port_20=YES    #主动模式端口为20
    ftp_data_port=20    #默认为20；指定主动模式的端口
    ```
+ 被动模式端口范围：
    ```sh
    pasv_min_port=XXX
    pasv_max_port=XXX
    #这两行规定了随机端口的范围；设置为0表示随机分配
    ```
+ 使用当地时间：
    ```sh
    use_localtime=YES
    #使用当地时间（默认为NO，使用GMT）

    ```
+ 认证相关：
    + 匿名用户：
        ```sh
        anonymous_enable=YES    #支持匿名用户
        no_anon_password=YES    #默认为NO；匿名用户略过口令检查
        anon_world_readable_only=YES    #默认没有此项，只有在虚拟用户的配置文件里才有效；为YES时，需要ftp用户对文件有读权限，other用户也必须有读的权限时才允许下载；为NO时，只需要ftp用户对文件有读权限就可下载
        anon_upload_enable=YES    #允许匿名用户上传
        anon_mkdir_write_enable=YES    #允许匿名用户上传
        anon_other_write_enable=YES    #允许匿名用户具有建立目录、上传之外的权限，如重命名、删除

        chown_uploads=YES    #默认为NO
        chown_username=qyh
        chown_upload_mode=0644
        #以上三行一起使用，指定上传文件的默认的所有者和权限
        ```
    + Linux用户：
        ```sh
        local_enable=YES    #是否允许Linux用户登录
        write_enable=YES    #允许Linux用户上传文件
        local_umask=022    #指定系统用户上传文件的默认权限
        guest_enable=YES    #所有系统用户都映射成guset用户
        guest_username=ftp    #配合上面选项才生效，指定guest
        local_root=/ftproot    #guest用户登录所在目录

        chroot_local_user=YES    #默认为NO（不禁锢）；禁锢所有系统用户在家目录中

        chroot_list_enable=YES
        chroot_list_file=/etc/vsftpd/chroot_list
        #禁锢或不禁锢特定系统用户在家目录中，与上面设置功能相反；
        #当chroot_local_user=YES时，chroot_list中用户不禁锢；
        #当chroot_local_user=NO时，chroot_list中用户禁锢；
        ```
+ vsftp日志：默认不启用
    ```sh
    dual_log_enable=YES    #使用vsftp日志格式，默认不启用
    vsftpd_log_file=/var/log/vsftpd.log    #此文件为默认，可自动生成
    ```
+ 登录提示信息：
    ```
    ftpd_banner="XXXX"
    banner_file=/etc/vsftpd/ftpbanner.txt
    ```
+ 目录访问提示信息：
    ```sh
    dirmessage_enable=YES    #默认
    message_file=.message    #默认，指定信息存放在指定目录下的.message
    ```
+ 使用pam（Pluggable Authentication Modules）完成用户认证：
    ```sh
    pam_service_name=vfstp

    #/etc/pam.d/vsftpd    pam配置文件
    #/etc/vsftpd/ftpusers    默认文件中用户拒绝登录
    ```
+ 是否启用控制用户登录的列表文件
    ```sh
    userlist_enable=YES    #默认文件中用户拒绝登录
    userlist_deny=YES    #默认值为YES；黑名单。不提示口令；NO为白名单
    userlist_file=/etc/vsftpd/user_list    #默认值
    ```
+ vsftpd服务指定用户身份运行：
    ```
    nopriv_user=nobody
    ```
+ 连接数限制：
    ```sh
    max_clients=0    #最大并发连接数
    max_per_ip=0    #每个IP同时发起的最大连接数
    ```
+ 传输速率：字节/秒
    ```sh
    anon_max_rate=0    #匿名用户的最大传输速率
    local_max_rate    #本地用户的最大传输速率
    ```
+ 连接时间：秒
    ```sh
    connect_timeout=60    #主动模式数据连接超时时长
    accept_timeout=60    #被动模式数据连接超时时长
    data_connection_timeout=300    #数据连接无数据传输超时时长
    idle_session_timeout=60    #无命令操作超时时长
    ```
+ 优先以文本方式传输：
    ```
    ascii_upload_enable=YES
    ascii_download_enable=YES
    ```
## vsftpd虚拟用户：
>虚拟用户：所有用户会用以映射为一个指定的账号来访问共享位置，即为此系统账号的家目录  
各虚拟用户可被赋予不同的访问权限，通过匿名用户的权限控制参数进行指定
+ 虚拟用户账号的存储方式：
    + 文件：
        + 编辑文本文件，此文件需要被编码为hash格式
            ```
            db_load -T -t hash -f vusers.txt vusers.db
            ```
        + 奇数行为用户名，偶数行为密码
    + 关系型数据库中的表中：
        + 实时查询数据库来完成用户认证
    + mysql库：
        + pam要依赖于pam-mysql
